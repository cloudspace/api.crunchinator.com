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
      num_workers.to_i.times do |index|
        @worker_threads << Thread.new(index) do |thread_index|
          worker = create_worker(thread_index + 1)
          worker.start
        end
      end
      @worker_threads.each(&:join)
      log 'all workers are now stopped'
      # return true if all workers exited normally, else false
      workers_completed?
    end

    # creates a single ApiQueue::Worker
    #
    # @param [String] id the name of this worker for purposes of logging
    # @return [ApiQueue::Worker] the worker that was created
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
        error_threshold_reached if too_many_errors?
      end
      log "WARNING: #{@error_count}/#{@error_threshold} consecutive errors" if @error_count > 0
    end

    # should be called if any worker is processing elements correctly
    # if all of the workers are failing, then this should not be called
    # eventually, the error count will be over the threshold and an error state will be triggered
    def reset_error_count
      @error_count_mutex.synchronize do
        @error_count = 0
      end
    end

    # this is called when the error threshold is reached, stopping all workers
    def error_threshold_reached
      stop_workers
    end

    # this determines if the error threshold has been exceeded or not
    #
    # @return [Boolean] true if over the threshold, else false
    def too_many_errors?
      @error_count >= @error_threshold
    end

    # did the workers exit because the job was done, or because of a failure?
    #
    # @return [Boolean] true if the workers exited due to an empty queue, else false
    def workers_completed?
      @workers.map { |worker| worker.succeeded }.uniq == [true]
    end

    # logs text into the logfile
    #
    # @param [String] text the text to be logged
    def log(text, id = nil)
      Rails.logger.info text
      File.open("#{Rails.root}/log/supervisor.log", 'a') do |f|
        f.puts(Time.now.strftime('%m/%d/%Y %T') + ' ' + (id ? "(worker #{id})" : '(supervisor)') + ' ' + text)
      end
    end
  end
end
