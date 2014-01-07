module ApiQueue
  class Supervisor

    def initialize(error_threshold: 50)
      # a place to store references to all the workers
      @workers = ThreadSafe::Array.new
      @worker_threads = ThreadSafe::Array.new

      # keep track of recent errors
      # if this @error_threshold or more api calls in a row raise
      # exceptions, the error_threshold_reached method will be called
      @error_threshold = error_threshold
      @error_count = 0
      @error_count_mutex = Mutex.new
    end

    # instantiates and starts queue workers. don't create more workers than
    # there are database connections, or the extra workers will sit idle
    # waiting for connections. rails seems to reserve 1-2 connections for
    # itself, so set a pool value in database.yml at least 2 higher
    # than the number of workers for best results
    #
    # @param [FixNum] num_workers the number of workers to start
    # @return [Array<Thread>] an array of threads, returned upon completion
    def start_workers(num_workers = 5, archive: [:local, :s3], process: true)
      @worker_threads = ThreadSafe::Array.new
      num_workers.times do |index|
        @worker_threads << Thread.new(index, archive, process) do |thread_index, archive, process|
          worker = ApiQueue::Worker.new(id: thread_index + 1, archive: archive, process: process, supervisor: self)
          @workers << worker
          worker.start
        end
      end

      @worker_threads.each(&:join)
    end

    # stops all the workers
    def stop_all
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
      stop_all
    end
  end
end