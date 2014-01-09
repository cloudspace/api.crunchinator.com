require 'json/stream'
module ApiQueue
  class Queue
    # A mutex to lock dequeueing actions at the class level
    @dequeue_mutex ||= Mutex.new

    # empties the queue
    # uses delete_all rather than destroy_all, since destroy_all makes a transaction
    # per element, which can be very slow when there are many elements on the queue
    def self.clear!
      ApiQueue::Element.delete_all
    end

    # Build a query string and insert is directly as a single sql statement. This is many times faster
    # than doing individual inserts or using the activerecord-import gem
    #
    # @param [Symbol, String] namespace the namespace for the permalinks (singular or plural)
    # @param [Array<String>] permalinks the permalinks to enqueue
    # @param [Symbol] data_source the api data source, options are :crunchbase, :s3, :local
    def self.batch_enqueue(namespace, permalinks, data_source = :crunchbase)
      unless permalinks.empty?
        namespace = namespace.to_s.singularize
        values = permalinks.uniq.map do |pl|
          "('#{data_source}', '#{namespace}', '#{pl}', current_timestamp, current_timestamp)"
        end
        sql = 'INSERT INTO api_queue_elements (data_source, namespace, permalink, created_at, updated_at) VALUES '
        sql << values.join(',')
        ApiQueue::Element.connection.execute(sql)
      end
    end

    # pushes a single element onto the queue
    #
    # @param [String] namespace the namespace for this element (singular)
    # @param [String] permalink the permalink to enqueue
    # @param [Symbol] data_source api data source, options are :crunchbase, :s3, :local
    # @return [ApiQueue::Element] the element created
    def self.enqueue(namespace, permalink, data_source = :crunchbase)
      ApiQueue::Element.create(permalink: permalink)
    end

    # dequeues a single element, marks it for processing, and returns it
    # if there is nothing left on the queue, it returns nil
    # this is a threadsafe, to prevent multiple workers from
    # processing the same element
    #
    # @return [ApiQueue::Element, nil] the element dequeued or nil if queue empty
    def self.dequeue
      @dequeue_mutex.synchronize do
        element = get_next_element
        if element
          Rails.logger.info "dequeueing element: #{element.inspect}"
          element.mark_for_processing
        else
          Rails.logger.info "there's nothing to dequeue!"
        end
        element
      end
    end

    # marks an element as completed, or records errors. increments num_runs, and turns off the processing flag
    #
    # @param [ApiQueue::Element] element the element to be updated
    # @param [String, nil] error the error message to be set, if any
    # @return [ApiQueue::Element] the element updated
    def self.update_element(element, error)
      if error
        element.update_attributes(error: error, num_runs: element.num_runs + 1,
                                  last_attempt_at: DateTime.now, processing: false)
      else
        element.update_attributes(complete: true, num_runs: element.num_runs + 1, processing: false)
      end
    end

    private

    # returns the next element in the queue
    #
    # @return [ApiQueue::Element, nil] the next element in the queue, or nil if empty
    def self.get_next_element
      ApiQueue::Element.pending.order_by_fifo.first
    end
  end
end
