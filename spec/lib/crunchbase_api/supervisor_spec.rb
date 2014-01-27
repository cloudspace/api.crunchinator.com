require 'spec_helper'

describe ApiQueue::Supervisor do
  describe 'class methods' do
    describe 'initialize' do
      it 'should assign instance variables to the default parameters' do
        supervisor = ApiQueue::Supervisor.new
        expect(supervisor.instance_variable_get(:@error_threshold)).to eq(50)
        expect(supervisor.instance_variable_get(:@archive)).to eq([:local, :s3])
        expect(supervisor.instance_variable_get(:@process)).to be_true
      end

      it 'should assign instance variables to the given parameters' do
        supervisor = ApiQueue::Supervisor.new(error_threshold: 40, archive: [:s3], process: false)
        expect(supervisor.instance_variable_get(:@error_threshold)).to eq(40)
        expect(supervisor.instance_variable_get(:@archive)).to eq([:s3])
        expect(supervisor.instance_variable_get(:@process)).to be_false
      end
    end
  end

  describe 'instance methods' do
    before(:each) do
      @supervisor = ApiQueue::Supervisor.new
    end

    describe 'public attributes' do
      it { expect(@supervisor).to respond_to(:archive) }
      it { expect(@supervisor).to respond_to(:process) }
    end

    describe 'start_workers' do
      before(:each) do
        @worker = double(ApiQueue::Worker)
        @worker.stub(:start)
        @supervisor.stub(:create_worker).and_return(@worker)
      end

      it 'should start a number of workers based on the args' do
        @supervisor.should_receive(:create_worker).with(1).and_return(@worker)
        @supervisor.start_workers(1)
      end

      it 'should start each worker on it\'s own thread' do
        @supervisor.start_workers(1)

        threads = @supervisor.instance_variable_get(:@worker_threads)
        expect(threads.size).to eq(1)
      end

      it 'should return the result of workers_completed?' do
        @supervisor.should_receive(:workers_completed?).and_return(true)
        expect(@supervisor.start_workers).to be_true
      end
    end

    describe 'create_worker' do
      it 'should create a worker with the given id' do
        worker = @supervisor.create_worker(5)
        expect(worker.instance_variable_get(:@id)).to eq(5)
      end

      it 'should add the worker to the worker list' do
        worker = @supervisor.create_worker(5)
        workers = @supervisor.instance_variable_get(:@workers)
        expect(workers).to include(worker)
      end
    end

    describe 'stop_workers' do
      it 'should call stop on each worker' do
        worker = double(ApiQueue::Worker)
        worker.should_receive(:stop)
        @supervisor.instance_variable_set(:@workers, [worker])
        @supervisor.stop_workers
      end
    end

    describe 'increment_error_count' do
      it 'should increase the error_count' do
        @supervisor.instance_variable_set(:@error_count, 10)
        @supervisor.increment_error_count
        expect(@supervisor.instance_variable_get(:@error_count)).to eq(11)
      end

      it 'should call error_threshold_reached if enough errors have occurred' do
        @supervisor.should_receive(:too_many_errors?).and_return(true)
        @supervisor.should_receive(:error_threshold_reached)
        @supervisor.increment_error_count
      end
    end

    describe 'reset_error_count' do
      it 'should set the error_count to 0' do
        @supervisor.instance_variable_set(:@error_count, 10)
        @supervisor.reset_error_count
        expect(@supervisor.instance_variable_get(:@error_count)).to eq(0)
      end
    end

    describe 'error_threshold_reached' do
      it 'should call stop_workers' do
        @supervisor.should_receive(:stop_workers)
        @supervisor.error_threshold_reached
      end
    end

    describe 'too_many_errors?' do
      it 'should return true if error count is greater or equal to error threshold' do
        @supervisor.instance_variable_set(:@error_threshold, 10)
        @supervisor.instance_variable_set(:@error_count, 10)
        expect(@supervisor.too_many_errors?).to be_true
      end
    end

    describe 'workers_completed?' do
      it 'should return true if all workers have succeeded' do
        worker = double(ApiQueue::Worker)
        worker.stub(:succeeded).and_return(true)

        @supervisor.instance_variable_set(:@workers, [worker])
        expect(@supervisor.workers_completed?).to be_true
      end

      it 'should return false if one of the workers has failed' do
        worker = double(ApiQueue::Worker)
        worker.stub(:succeeded).and_return(false)

        @supervisor.instance_variable_set(:@workers, [worker])
        expect(@supervisor.workers_completed?).to be_false
      end
    end

    describe 'log' do
      # skipping tests for now
    end
  end
end
