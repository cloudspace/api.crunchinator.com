require 'spec_helper'

describe ApiQueue do
  describe 'class methods' do
    describe 'method_missing' do
      it 'should attempt to call a method on the Controller' do
        ApiQueue::Controller.should_receive(:hard_reset!)
        ApiQueue.hard_reset!
      end
    end

    describe 'respond_to?' do
      it 'should return true if the symbol is a method on the Controller' do
        expect(ApiQueue.respond_to?(:hard_reset!)).to be_true
      end
    end

    describe 'methods' do
      it 'should include Controller methods' do
        expect(ApiQueue.methods).to include(:hard_reset!)
      end
    end
  end
end

describe ApiQueue::Controller do
  describe 'class methods' do
    before(:each) do
      ApiQueue::Controller.stub(:log)
    end

    describe 'hard_reset!' do
      before(:each) do
        ApiQueue::Queue.stub(:clear!)
        File.stub(:delete)
      end

      it 'should clear the queue' do
        ApiQueue::Queue.should_receive(:clear!)
        ApiQueue::Controller.hard_reset!
      end

      it 'should delete the logs' do
        `touch #{Rails.root}/log/import_worker_1.log`
        `touch #{Rails.root}/log/supervisor.log`
        `touch #{Rails.root}/log/controller.log`

        File.should_receive(:delete).with("#{Rails.root}/log/import_worker_1.log")
        File.should_receive(:delete).with("#{Rails.root}/log/supervisor.log")
        File.should_receive(:delete).with("#{Rails.root}/log/controller.log")

        ApiQueue::Controller.hard_reset!
      end
    end

    describe 'run' do
      before(:each) do
        ApiQueue::Controller.stub(:populate)
        ApiQueue::Controller.stub(:start_workers)
        ApiQueue::Controller.stub(:upload)
        ApiQueue::Controller.stub(:cache_json)
      end

      it 'should populate the queue' do
        ApiQueue::Controller.should_receive(:populate).with(data_source: :crunchbase)
        ApiQueue::Controller.run(data_source: :crunchbase)
      end

      it 'should start workers' do
        ApiQueue::Controller.should_receive(:start_workers).with(3)
        ApiQueue::Controller.run(3)
      end

      it 'should upload fake data if all conditions are met' do
        ApiQueue::Controller.stub(:upload).and_return(true)
        ApiQueue::Controller.stub(:start_workers).and_return(true)
        ApiQueue::Controller.should_receive(:cache_json)
        ApiQueue::Controller.run
      end

      it 'should not upload fake data if the workers stopped before finishing' do
        ApiQueue::Controller.stub(:upload).and_return(true)
        ApiQueue::Controller.stub(:start_workers).and_return(false)
        ApiQueue::Controller.should_not_receive(:cache_json)
        ApiQueue::Controller.run
      end
    end

    describe 'start_workers' do
      it 'should create a new supervisor and call start workers on it' do
        supervisor = ApiQueue::Supervisor.new
        ApiQueue::Supervisor.stub(:new).and_return(supervisor)
        supervisor.should_receive(:start_workers).with(3)

        ApiQueue::Controller.start_workers(3)
      end
    end

    describe 'populate' do
      before(:each) do
        ApiQueue::Source::S3.stub(:fetch_entities).and_return([])
        ApiQueue::Queue.stub(:batch_enqueue)
      end

      it 'should pick a source based on the input' do
        ApiQueue::Source::S3.should_receive(:fetch_entities)
        ApiQueue::Controller.populate(data_source: :s3)
      end

      it 'should batch enqueue for each namespace' do
        ApiQueue::Queue.should_receive(:batch_enqueue).with(:company, [], :s3)
        ApiQueue::Controller.populate(data_source: :s3, namespace: :company)
      end
    end

    describe 'populate!' do
      before(:each) do
        ApiQueue::Queue.stub(:clear!)
        ApiQueue::Controller.stub(:populate)
      end

      it 'should clear the queue' do
        ApiQueue::Queue.should_receive(:clear!)
        ApiQueue::Controller.populate!
      end

      it 'should call populate' do
        ApiQueue::Controller.should_receive(:populate)
        ApiQueue::Controller.populate!
      end
    end

    describe 'populate_all!' do
      before(:each) do
        ApiQueue::Queue.stub(:clear!)
        ApiQueue::Controller.stub(:populate)
      end

      it 'should clear the queue' do
        ApiQueue::Queue.should_receive(:clear!)
        ApiQueue::Controller.populate_all!
      end

      it 'should populate all of the namespaces' do
        ApiQueue::Controller.should_receive(:populate)
          .with(data_source: :s3, namespaces: %w[company person financial-organization])
        ApiQueue::Controller.populate_all!(data_source: :s3)
      end
    end

    describe 'populate_missing' do
      it 'should only include permalinks that are not already in s3' do
        ApiQueue::Source::Crunchbase.stub(:fetch_entities).and_return(%w[cloudspace google])
        ApiQueue::Source::S3.stub(:fetch_entities).and_return(['cloudspace'])
        ApiQueue::Queue.should_receive(:batch_enqueue).with(:company, ['google'], :crunchbase)

        ApiQueue::Controller.populate_missing(data_source: :crunchbase, namespace: :company)
      end
    end

    describe 'cache_json' do
      it 'should upload data for each endpoint' do
        sample_response = double
        sample_response.stub(:body).and_return('{"hello": "world"}')
        ApiQueue::Controller.stub(:query_app).and_return(sample_response)

        version = Crunchinator::Application::VERSION

        ApiQueue::Source::S3.should_receive(:upload_and_expose)
          .with("api/#{version}/categories.json", sample_response.body)
        ApiQueue::Source::S3.should_receive(:upload_and_expose)
          .with("api/#{version}/companies.json", sample_response.body)
        ApiQueue::Source::S3.should_receive(:upload_and_expose)
          .with("api/#{version}/investors.json", sample_response.body)
        ApiQueue::Source::S3.should_receive(:upload_and_expose)
          .with('api/current_release.json', "{\"release\":\"#{version}\"}", gzip: false)
        ApiQueue::Controller.cache_json
      end
    end

    describe 'query_app' do
      it 'should fake a call to a controller to get it\'s json response' do
        app = ActionDispatch::Integration::Session.new(Crunchinator::Application)
        ActionDispatch::Integration::Session.stub(:new).and_return(app)
        app.should_receive(:send).with(:get, '/v1/companies')

        ApiQueue::Controller.query_app(controller_method: :get, endpoint: :companies)
      end
    end

    describe 'log' do
    end
  end
end
