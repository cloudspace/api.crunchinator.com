puts 'hello'
# the basic idea for this class was stolen from the query_diet gem
module QueryCounter

  def self.setup 
    @query_count = 0

    ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
      def log_with_query_count(query, *args, &block)
        QueryCounter.increment(query)
        log_without_query_count(query, *args, &block)
      end

      alias_method :log_without_query_count, :log
      alias_method :log, :log_with_query_count
    end
  end

  def self.cleanup
    ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
      alias_method :log, :log_without_query_count
    end
  end

  def self.reset
    @query_count = 0
  end

  def self.over_threshold?
    @query_count > 25
  end

  def self.increment(query)
    @query_count += 1 if countable_query?(query)
  end

  def self.countable_query?(query)
    output = query =~ /^(select|create|update|delete|insert)\b/i
    output
  end

  def self.count
    @query_count
  end
end
