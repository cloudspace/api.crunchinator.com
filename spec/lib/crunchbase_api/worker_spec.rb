require 'spec_helper'

describe ApiQueue::Worker do
  describe 'class methods' do
    describe 'initialize' do
      it 'should set state based on default values' do
        worker = ApiQueue::Worker.new
        expect(worker.instance_variable_get(:@id)).to be_nil
        expect(worker.instance_variable_get(:@supervisor)).to be_nil
      end

      it 'should set state based on given values' do
        supervisor = ApiQueue::Supervisor.new
        worker = ApiQueue::Worker.new(id: 5, supervisor: supervisor)

        expect(worker.instance_variable_get(:@id)).to eq(5)
        expect(worker.instance_variable_get(:@supervisor)).to eq(supervisor)
      end
    end
  end

  describe 'instance methods' do
    before(:each) do
      @supervisor = ApiQueue::Supervisor.new
      @worker = ApiQueue::Worker.new(id: 1, supervisor: @supervisor)
    end

    describe 'start' do
      before(:each) do
        @worker.stub(:fetch_and_parse_next_element).and_return(false)
      end

      # it 'should call supervisor.stop_workers on an interrupt and set running to false' do
      #   thread = Thread.new do |t|
      #     worker = ApiQueue::Worker.new(id: 1, supervisor: @supervisor)

      #     def worker.raise_interrupt
      #       raise Interrupt
      #     end
      #     worker.start
      #     @supervisor.should_receive(:stop_workers)
      #     worker.raise_interrupt
      #   end

      #   thread.join
      # end

      it 'should fetch and parse next element until it returns false' do
        @worker.should_receive(:fetch_and_parse_next_element).and_return(false)
        @worker.start
      end

      it 'after finishing the parse loop, it should set succeeded to the value of running' do
        @worker.start
        expect(@worker.instance_variable_get(:@succeeded)).to be_true
      end
    end

    describe 'fetch_and_parse_next_element' do
      before(:each) do
        @element = ApiQueue::Element.new

        @worker.stub(:retry_or_dequeue).and_return(@element)
        @worker.stub(:fetch_entity)
        @worker.stub(:process_response)
      end

      it 'should return true if an element is found' do
        # note that retry_or_dequeue is stubbed in the before
        expect(@worker.fetch_and_parse_next_element).to be_true
      end

      it 'should return false if no element is found' do
        @worker.stub(:retry_or_dequeue).and_return(false)
        expect(@worker.fetch_and_parse_next_element).to be_false
      end

      it 'should call retry_or_dequeue to determine the next element' do
        @worker.should_receive(:retry_or_dequeue)
        @worker.fetch_and_parse_next_element
      end

      it 'should return false if retry_or_dequeue returns a nil' do
        @worker.stub(:retry_or_dequeue).and_return(false)
        expect(@worker.fetch_and_parse_next_element).to be_false
      end

      it 'should call fetch_entity' do
        @worker.should_receive(:fetch_entity)
        @worker.fetch_and_parse_next_element
      end

      it 'should call process_response with the return value from fetch_entity' do
        @worker.stub(:fetch_entity).and_return('hello' => 'world')
        @worker.should_receive(:process_response).with('hello' => 'world')
        @worker.fetch_and_parse_next_element
      end

      it 'should call record_error if any error is raised' do
        @worker.stub(:fetch_entity).and_raise('Exception')
        @worker.should_receive(:record_error)
        @worker.fetch_and_parse_next_element
      end

      it 'should call update_element on the queue' do
        queue = double(ApiQueue::Queue)
        queue.should_receive(:update_element)

        @worker.instance_variable_set(:@queue, queue)
        @worker.fetch_and_parse_next_element
      end

      it 'should reset the error count on the supervisor if there was no error' do
        @supervisor.should_receive(:reset_error_count)
        @worker.instance_variable_set(:@error, nil)

        @worker.fetch_and_parse_next_element
      end

      it 'if should_retry? is true, it should set the current element to the previous element' do
        @worker.stub(:should_retry?).and_return(true)

        @worker.fetch_and_parse_next_element
        expect(@worker.instance_variable_get(:@previous_element)).to eq(@element)
      end
    end

    describe 'should_retry?' do
      it 'should return true if the error and element are set, and the retry count is low' do
        element = double(ApiQueue::Element)
        element.stub(:num_runs).and_return(1)
        @worker.instance_variable_set(:@error, 'An error has occurred')
        @worker.instance_variable_set(:@element, element)

        expect(@worker.should_retry?).to be_true
      end
    end

    describe 'retry_or_dequeue' do
      it 'should return the previous element if it is set' do
        element = double(ApiQueue::Element)
        @worker.instance_variable_set(:@previous_element, element)
        expect(@worker.retry_or_dequeue).to eq(element)
      end

      it 'should dequeue an element otherwise' do
        queue = double(ApiQueue::Queue)
        queue.should_receive(:dequeue)
        @worker.instance_variable_set(:@queue, queue)

        @worker.retry_or_dequeue
      end
    end

    describe 'fetch_entity' do
      it 'should fetch the json from the api/data source' do
        element = ApiQueue::Element.new
        element.should_receive(:data_source)
        element.should_receive(:namespace).exactly(2).times
        element.should_receive(:permalink).exactly(2).times
        @worker.instance_variable_set(:@element, element)

        api = ApiQueue::Source::Crunchbase
        api.should_receive(:fetch_entity)

        @worker.should_receive(:api).and_return(api)

        @worker.fetch_entity
      end
    end

    describe 'process_response' do
      before(:each) do
        @response = '{"hello": "world"}'
        @worker.stub(:archive_data)
        @worker.stub_chain(:parser, :process_entity)
        @worker.stub(:process_json?)

        element = double(ApiQueue::Element)
        element.stub(:namespace)
        @worker.instance_variable_set(:@element, element)
      end

      it 'should archive the json' do
        @worker.should_receive(:archive_data).with(@response)
        @worker.process_response(@response)
      end

      it 'should call process_entity on the parser with the parsed json' do
        parser = double(ApiQueue::Parser::Company)
        @worker.stub(:parser).and_return(parser)
        @worker.stub(:process_json?).and_return(true)

        parser.should_receive(:process_entity).with('hello' => 'world')
        @worker.process_response(@response)
      end
    end

    describe 'stop' do
      it 'should set running to false' do
        @worker.send(:stop)
        expect(@worker.instance_variable_get(:@running)).to be_false
      end
    end

    describe 'api' do
      it 'should return the api constant' do
        expect(@worker.api('crunchbase')).to eq(ApiQueue::Source::Crunchbase)
      end
    end

    describe 'parser' do
      it 'should return the parser instance' do
        expect(@worker.parser('company')).to be_a(ApiQueue::Parser::Company)
      end
    end

    # private methods

    describe 'log' do
      it 'should call the supervisor log' do
        @supervisor.should_receive(:log).with('text', @worker.instance_variable_get(:@id))
        @worker.send(:log, 'text')
      end
    end

    describe 'archive_locations' do
      it 'should call the supervisor archive' do
        @supervisor.should_receive(:archive)
        @worker.send(:archive_locations)
      end
    end

    describe 'process_json?' do
      it 'should call the supervisor process' do
        @supervisor.should_receive(:process)
        @worker.send(:process_json?)
      end
    end

    describe 'archive_data' do
      it 'should save the json response to the appropriate location' do
        data = '{"hello": "world"}'

        @worker.stub(:archive_locations).and_return('s3')
        element = ApiQueue::Element.new(data_source: 'crunchbase')
        @worker.instance_variable_set(:@element, element)

        ApiQueue::Source::S3.should_receive(:save_entity)

        @worker.send(:archive_data, data)
      end
    end

    describe 'record_error' do
      before(:each) do
        @exception = double(StandardError.new)
        @exception.stub(:message).and_return('the message')
        @exception.stub(:backtrace).and_return([])
      end

      it 'should increment the error count' do
        @supervisor.should_receive(:increment_error_count)
        @worker.send(:record_error, @exception)
      end

      it 'should call log' do
        @worker.should_receive(:log)
        @worker.send(:record_error, @exception)
      end
    end
  end
end
