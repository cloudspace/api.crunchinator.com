module ApiQueue
  # The queue worker implementation. Workers take elements off the queue,
  # query the api, and attempts to produce objects from the result.
  #
  # NOTE: ALL exceptions should be handled by the queue worker in the run method,
  # and not by any of the other classes within ApiQueue, in order for errors to
  # be properly logged and recovered. Components that handle their own exceptions
  # will be much harder to debug. IF IT IS GOING TO BREAK, LET IT BREAK.
  class Worker

    def initialize(id: nil, supervisor: nil)
      @running = false                  # a flag used to stop workers
      @id = id                          # used for logging purposes
      @supervisor = supervisor          # set a reference to this worker's supervisor
      @queue = ApiQueue::Queue          # the queue could be swapped out later
    end

    # this sets a worker in motion. the worker will stop running
    # if the stop method is called on it, or the queue is empty
    def start
      log "Initializing worker #{@id}..."
      @running = element_found = true

      # this allows interrupts to be caught and stop the workers
      # there has to be a better way than this, but i couldn't
      # figure out how
      # TODO: find a better way to handle interrupts gracefully
      Kernel.trap('INT') { @supervisor.stop_workers }

      # this is the main loop. workers continue to loop until
      # their stop method is called, or the queue is empty
      while @running && element_found
        element_found = fetch_and_parse_next_element
      end
    end

    def fetch_and_parse_next_element
      begin
        @error = nil
        @element = retry_or_dequeue
        return false unless @element

        response = fetch_entity
        process_response(response)
      rescue StandardError => e
        record_error(e)
      end

      # if everything worked, flag the element as complete.
      # if anything went wrong, log the error, incremement the error counter,
      # and set the retry flag if the element hasn't hit the retry limit.
      @queue.update_element(@element, @error)
      @supervisor.reset_error_count unless @error

      @previous_element = should_retry? ? @element : nil
      true
    end

    def should_retry?
      @error && @element && @element.num_runs < 5
    end

    def retry_or_dequeue
      if @previous_element
        @previous_element
      else
        @queue.dequeue
      end
    end

    # pulls from the remote api, handles qps issues by sleeping and retrying silently
    def fetch_entity
      # log the element, get the api singleton, and trigger the api call
      log "#{Time.now.to_s} - Processing #{@element.namespace.to_s.singularize} #{@element.permalink.inspect}"
      api(@element.data_source).fetch_entity(@element.namespace, @element.permalink)
    end

    def process_response(response_body)
      # turn the json into a hash
      # There is no utf-8 representation of an ASCII record seperator, which causes the
      # json serializer to be sad. The code:
      #     gsub(/[[:cntrl:]]/, '')
      # replaces this unidentified character.
      entity = JSON::Stream::Parser.parse(response_body.gsub(/[[:cntrl:]]/, ''))

      # save the raw text response to the specified archive targets
      archive_data(response_body)

      # if the process flag is truthy, save the objects in the db.
      parser(@element.namespace).process_entity(entity) if process_json?
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

    def api(api_name)
      "ApiQueue::Source::#{api_name.to_s.classify}".constantize
    end

    def parser(namespace)
      "ApiQueue::Parser::#{namespace.to_s.classify}".constantize.new
    end

    private

    def archive_locations
      @supervisor.archive
    end

    def process_json?
      @supervisor.process
    end

    # save the json payload for the current element to a local file and/or s3
    # don't save to the source, For example, if an element's data_source is
    # local, then don't save it back to local
    def archive_data(data)
      if data.present?
        [*archive_locations].each do |target_name|
          if target_name.present? && target_name.to_sym != @element.data_source.to_sym
            target = api(target_name)
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
      log(('=' * 90) + "\nERROR processing data!" + @error)
    end
  end
end
