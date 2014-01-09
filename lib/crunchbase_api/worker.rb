# Takes elements off the queue, queries the api, and attempts to produce
# objects from the result.
#
# NOTE: ALL exceptions should be handled by the queue worker in the run method,
# and not by any of the other classes within ApiQueue, in order for errors to
# be properly logged and recovered. Components that handle their own exceptions
# will be much harder to debug. IF IT IS GOING TO BREAK, LET IT BREAK.
module ApiQueue
  class Worker

    def initialize(id: nil, process: true, archive: [:local, :s3], supervisor: nil)
      @archive = archive                # the target(s) for archiving the json responses
      @process = process                # insert into the db or just move files?
      @running = false                  # a flag used to stop workers
      @retry = false                    # a flag used to retry after errors
      @id = id                          # used for logging purposes
      @supervisor = supervisor          # set a reference to this worker's supervisor
      @queue = ApiQueue::Queue          # the queue could be swapped out later
    end

    # this sets a worker in motion. the worker will stop running
    # if the stop method is called on it, or the queue is empty
    def start
      log "Initializing worker #{@id}..."
      @running = true

      # this allows interrupts to be caught and stop the workers
      # there has to be a better way than this, but i couldn't
      # figure out how
      # TODO: find a better way to handle interrupts gracefully
      Kernel.trap('INT') { @supervisor.stop_all }

      # this is the main loop. workers continue to loop until
      # their stop method is called, or the queue is empty
      while @running
        begin
          # wipe relevant instance variables to avoid using the last element's data
          @error = @response = @response_body = @response_code = @entity = nil

          # if the retry flag is set, unset it and use the element
          # from the last iteration. if it is not set, attempt to get
          # a new element from the queue. if none is available, halt
          if @retry
            @retry = false
          else
            @element = @queue.dequeue || break
          end

          # @retry &&= false || @element = @queue.dequeue || break

          # log the element, get the api singleton, and trigger the api call
          log "#{Time.now.to_s} - Processing #{@element.namespace.to_s.singularize} #{@element.permalink.inspect}"
          @response = api.get_entity(@element.namespace, @element.permalink)
          @response_code = @response.respond_to?(:code) ? @response.code : '200'
          @response_body = @response.respond_to?(:body) ? @response.body : @response

          # if QPS rate limiting is detected, sleep the thread for 1 minute, then
          # try again. this doesn't count toward the maximum 5 errors per element,
          # nor does it increment the error_count, since QPS rate limiting has nothing
          # to do with this specific entity. The sleep should provide a crude form of throttling
          # TODO: find a better way to handle error codes than right here in the main loop
          # TODO: make this only happen when the api source is crunchbase
          if @response_code == '403' && @response_body == '<h1>Developer Over Qps</h1>'
            log ('*' * 90) + "\nQPS RATE LIMITING DETECTED\n" + ('*' * 90)
            @retry = true
            sleep(60)
            next
          end

          # turn the json into a hash
          # There is no utf-8 representation of an ASCII record seperator, which causes the
          # json serializer to be sad. The code:
          #     gsub(/[[:cntrl:]]/, '')
          # replaces this unidentified character.
          @entity = JSON::Stream::Parser.parse(@response_body.gsub(/[[:cntrl:]]/, ''))

          # save the raw text response to the specified archive targets
          archive_data(@response_body)

          # if the process flag is truthy, save the objects in the db.
          parser.process_entity(@entity) if @process

        # all exceptions should be allowed to bubble up to here to be handled and logged.
        rescue StandardError => e
          # increment the error counter, log the error
          record_error(e)
        end

        # if everything worked, flag the element as complete.
        # if anything went wrong, log the error, incremement the error counter,
        # and set the retry flag if the element hasn't hit the retry limit.
        @queue.update_element(@element, @error) if @element
        @supervisor.reset_error_count unless @error
        @retry = true if @error && @element && @element.num_runs < 5
      end
    end

    # stops the worker after the current iteration
    def stop
      Rails.logger.info "STOPPING WORKER #{@id}!"
      log "STOPPING WORKER #{@id}!"
      @running = false
    end

    # logs text into the logfile corresponding to the worker's @id
    #
    # @param [String] text the text to be logged
    def log(text)
      File.open("log/import_worker#{(@id ? '_' + @id.to_s : '')}.log", 'a') { |f| f.puts(text) }
    end

    def api
      get_api(@element.data_source)
    end

    def get_api(api_name)
      "ApiQueue::Source::#{api_name.to_s.classify}".constantize
    end

    def parser
      get_parser(@element.namespace)
    end

    def get_parser(namespace)
      "ApiQueue::Parser::#{namespace.to_s.classify}".constantize
    end

    def next_element

    end

    private

    # save the json payload for the current element to a local file and/or s3
    # don't save to the source, For example, if an element's data_source is
    # local, then don't save it back to local
    def archive_data(data)
      if data.present?
        [*@archive].each do |target_name|
          if target_name.present? && target_name.to_sym != @element.data_source.to_sym
            target = get_api(target_name)
            log "archiving #{@element.namespace.to_s.pluralize}/#{@element.permalink}.json to #{target_name.inspect}"
            target.save_entity(@element.namespace, @element.permalink, data)
          end
        end
      end
    end

    # record an exception, and if the count reaches the threshold,
    # it triggers the error_threshold_reached method also
    # logs the error text to the logfile and on the element itself
    def record_error(exception)
      @supervisor.increment_error_count

      @error = exception.message + "\n" + exception.backtrace.join("\n") +
        "\n#{('-' * 90)}\nQUEUE ELEMENT:\n#{@element.inspect}" +
        "\n#{('-' * 90)}\nRAW PAYLOAD:\n#{@response.inspect}" +
        "\n#{('-' * 90)}\nRAW BODY:\n#{@response_body.inspect}" +
        "\n#{('-' * 90)}\nPARSED PAYLOAD:\n#{@entity.inspect}"
      log ('=' * 90) + "\nERROR processing data!" + @error
    end
  end
end
