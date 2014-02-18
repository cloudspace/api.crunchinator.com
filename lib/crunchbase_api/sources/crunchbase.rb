module ApiQueue
  module Source
    # An interface to interact with the crunchbase API and serve JSON data to queue workers
    #
    # The plural available namespaces are:
    # ['companies', 'people', 'financial-organizations', 'products', 'service-providers']
    class Crunchbase

      # Retrieves the list of permalinks corresponding to entities for which Crunchbase has data
      #   within the specified namespace.
      #
      # @param [Symbol,String] namespace The type of entity (company, person, etc)
      # @return [Array] the list of permalinks.
      def self.fetch_entities(namespace)
        plural_namespace = namespace.to_s.pluralize
        response = HTTParty.get("http://api.crunchbase.com/v/1/#{plural_namespace}.js?api_key=#{api_key}")
        # tweak the JSON to correct malformed JSON we have seen which prevents parsing
        response_body = response.body.gsub(/[[:cntrl:]]/, '').gsub('"}][{"', '"},{"')
        JSON::Stream::Parser.parse(response_body).map { |c| c['permalink'] }
      end

      # Retrieves json data corresponding to the company with the specified permalink
      #
      # @param [Symbol,String] namespace The type of entity
      # @param [Symbol,String] permalink The permalink for this entity
      # @return [String] JSON data for the specified entity
      def self.fetch_entity(namespace, permalink)
        should_retry = true
        while should_retry
          uri = entity_uri(namespace, permalink)
          response = HTTParty.get(uri)
          should_retry = rate_limited?(response)
          sleep(60) if should_retry
        end
        response.code == 200 ? response.body : handle_failure(response)
      end

      private

      # produces a uri complete wit
      def self.entity_uri(namespace, permalink)
        "http://api.crunchbase.com/v/1/#{namespace.to_s.singularize}/#{permalink}.js?api_key=#{api_key}"
      end

      # Checks a response to see if it has been rate limited
      #
      # @param [HTTParty::Response] response the response to check
      # @return [Boolean] true if rate limited, else false
      def self.rate_limited?(response)
        response.code == 403 && response.body == '<h1>Developer Over Qps</h1>'
      end

      # Raises an exception with useful information associated
      #
      # @param [HTTParty::Response] response the failed response used to generate the message
      def self.handle_failure(response)
        fail "#{response.response.class} #{response.code} #{response.message}"
      end

      # The API key for crunchbase
      #
      # @return [String] the API key
      def self.api_key
        ENV['CRUNCHBASE_API_KEY']
      end
    end
  end
end
