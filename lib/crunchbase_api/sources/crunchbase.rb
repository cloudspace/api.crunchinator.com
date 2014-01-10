module ApiQueue
  module Source
    # Both methods should parse the json, handle errors, and return ruby hashes.
    # Saving data to S3 should happen automatically if necessary.
    # The source parameter will try to get the data from local/s3/crunchbase as specified.
    # No additional data should be passed in such as api keys.
    #
    # Make sure that unexpected html or xml responses are handled.
    #
    # The plural available namespaces are:
    # ['companies', 'people', 'financial-organizations', 'products', 'service-providers']
    #
    # Syntax:
    #
    # For all entities except people:
    # http://api.crunchbase.com/v/1/<plural entity namespace>/permalink?name=<entity name>
    #
    # For people:
    # http://api.crunchbase.com/v/1/people/permalink?first_name=<person first name>&last_name=<person last name>
    #
    # EXAMPLES:
    # http://api.crunchbase.com/v/1/<plural entity namespace>/permalink?name=<entity name>
    # http://api.crunchbase.com/v/1/companies/permalink?name=Google
    # http://api.crunchbase.com/v/1/financial-organizations/permalink?name=Sequoia%20Capital
    # http://api.crunchbase.com/v/1/products/permalink?name=iPhone
    # http://api.crunchbase.com/v/1/people/permalink?first_name=Ron&last_name=Conway
    class Crunchbase

      # Retrieves the list of companies Crunchbase/S3 has data for.
      #
      # @return [Hash] the list of companies.
      def self.get_entities(namespace)
        plural_namespace = namespace.to_s.pluralize
        response = Net::HTTP.start('api.crunchbase.com') do |http|
          http.get("/v/1/#{plural_namespace}.js?api_key=#{ENV['CRUNCHBASE_API_KEY']}").body.gsub(/[[:cntrl:]]/, '')
        end
        JSON::Stream::Parser.parse(response).map { |c| c['permalink'] }
      end

      def self.get_random_entities(namespace = :companies, n = 2000)
        get_entities(namespace).sample(n)
      end

      def self.get_entity(namespace, permalink, limit: 10, uri_str: nil)
        fail ArgumentError, 'too many HTTP redirects' if limit == 0
        uri_str ||= build_uri(namespace, permalink)
        response = Net::HTTP.get_response(URI(uri_str))
        catch :redirect do
          handler_klass = "ApiQueue::Response::#{response.class.to_s.split('::').last.sub('HTTP', '')}".constantize
          return handler_klass.new.handle(response).body
        end
        location = response['location'] + "?api_key=#{ENV['CRUNCHBASE_API_KEY']}"
        Rails.logger.info "redirected to #{location}"
        get_entity(namespace, permalink, limit: limit - 1, uri_str: location)
      end

      private

      def self.build_uri(namespace, permalink)
        singular_namespace = namespace.to_s.singularize
        "http://api.crunchbase.com/v/1/#{singular_namespace}/#{permalink}.js?api_key=#{ENV['CRUNCHBASE_API_KEY']}"
      end
    end
  end
end
