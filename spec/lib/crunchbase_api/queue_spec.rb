require 'spec_helper'

describe 'ApiQueue::Queue' do
  describe 'class methods' do
    describe 'clear!' do
      it 'should delete all elements' do
        ApiQueue::Element.should_receive(:delete_all)
        ApiQueue::Queue.clear!
      end
    end

    describe 'batch_enqueue' do
      it 'should do nothing if not given any permalinks' do
        ApiQueue::Queue.should_not_receive(:batch_enqueue_sql)
        ApiQueue::Queue.batch_enqueue('companies', [])
      end

      # This test sucks but it works.  Sorry (JH 1-23-2013).
      it 'should build and execute sql statements' do
        ApiQueue::Queue.should_receive(:batch_enqueue_sql).and_return('select 1')
        result = ApiQueue::Queue.batch_enqueue('companies', ['cloudspace'])
        expect(result.getvalue(0, 0)).to eq('1')
      end
    end

    describe 'batch_enqueue_sql' do
      it 'should create a big insert statement' do
        sql = 'INSERT INTO api_queue_elements ' +
          '(data_source, namespace, permalink, created_at, updated_at)' +
          ' VALUES ' +
          '(\'crunchbase\', \'company\', \'cloudspace\', current_timestamp, current_timestamp)'
        expect(ApiQueue::Queue.batch_enqueue_sql('companies', ['cloudspace'], :crunchbase)).to eq(sql)
      end
    end

    describe 'enqueue' do
      it 'should create a queue element' do
        ApiQueue::Element.should_receive(:create).with(permalink: 'cloudspace')
        ApiQueue::Queue.enqueue('companies', 'cloudspace')
      end
    end

    describe 'dequeue' do
      it 'should find the next element, mark it for processing, and return it' do
        element = ApiQueue::Element.new
        ApiQueue::Queue.should_receive(:next_element).and_return(element)
        element.should_receive(:mark_for_processing)
        expect(ApiQueue::Queue.dequeue).to eq(element)
      end

      it 'should return nil if it can\'t find the next element' do
        ApiQueue::Queue.stub(:next_element).and_return(nil)
        expect(ApiQueue::Queue.dequeue).to be_nil
      end
    end

    describe 'update_element' do
      before(:each) do
        @element = ApiQueue::Element.new
      end

      it 'should set error information if there is an error' do
        ApiQueue::Queue.update_element(@element, 'there is an error')
        expect(@element.error).to eq('there is an error')
        expect(@element.last_attempt_at).not_to be_nil
        expect(@element.complete).to be_false
      end

      it 'should set completed to true if there is no error' do
        ApiQueue::Queue.update_element(@element, nil)
        expect(@element.error).to be_nil
        expect(@element.last_attempt_at).to be_nil
        expect(@element.complete).to be_true
      end
    end

    describe 'next_element' do
      it 'should use scopes on the queue element model to figure out which element to pull next' do
        element = ApiQueue::Element.new
        ApiQueue::Element.stub_chain(:pending, :order_by_fifo).and_return([element])
        expect(ApiQueue::Queue.next_element).to eq(element)
      end
    end
  end
end
