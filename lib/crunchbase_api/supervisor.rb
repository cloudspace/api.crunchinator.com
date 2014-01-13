module ApiQueue
  # Supervises ApiQueue::Worker objects. Creates, controls, starts, and stops workers as needed
  class Supervisor

    def initialize(error_threshold: 50, archive: [:local, :s3], process: true)
      # a place to store references to all the workers
      @workers = ThreadSafe::Array.new
      @worker_threads = ThreadSafe::Array.new
      @archive = archive # the target(s) for archiving the json responses
      @process = process # insert into the db or just move files?

      # keep track of recent errors
      # if this @error_threshold or more api calls in a row raise
      # exceptions, the error_threshold_reached method will be called
      @error_threshold = error_threshold
      @error_count = 0
      @error_count_mutex = Mutex.new
    end

    attr_accessor :archive, :process

    # instantiates and starts queue workers. don't create more workers than
    # there are database connections, or the extra workers will sit idle
    # waiting for connections. rails seems to reserve 1-2 connections for
    # itself, so set a pool value in database.yml at least 2 higher
    # than the number of workers for best results
    #
    # @param [FixNum] num_workers the number of workers to start
    # @return [Array<Thread>] an array of threads, returned upon completion
    def start_workers(num_workers = 5)
      num_workers.times do |index|
        @worker_threads << Thread.new(index) do |thread_index|
          worker = create_worker(thread_index + 1)
          worker.start
        end
      end

      @worker_threads.each(&:join)
    end

    def create_worker(id)
      worker = ApiQueue::Worker.new(id: id, supervisor: self)
      @workers << worker
      worker
    end

    # stops all the workers
    def stop_workers
      @workers.map(&:stop)
    end

    # increment the error count
    def increment_error_count
      @error_count_mutex.synchronize do
        @error_count = @error_count + 1
        error_threshold_reached if @error_count >= @error_threshold
      end
    end

    # reset the error count to 0
    def reset_error_count
      @error_count_mutex.synchronize do
        @error_count = 0
      end
    end

    # use this to set what the workers should do if
    # the error threshold is reached
    # for now just stop all the workers
    # TODO: decide whether sleeping or stopping is appropriate
    def error_threshold_reached
      stop_workers
    end
  end
end
