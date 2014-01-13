module ApiQueue
  module Source
    # An interface to interact with the local filesystem and serve JSON data to queue workers
    # as well as save data to local files. Files are saved to /json_data/<namespace>/<filename>
    class Local

      # Retrieves the list of permalinks corresponding to entities for which there is data on s3
      #
      # @param [Symbol,String] namespace The type of entity (company, person, etc)
      # @return [Array] the list of permalinks.
      def self.fetch_entities(namespace)
        plural_namespace = namespace.to_s.pluralize
        folder = "#{Rails.root}/json_data/#{plural_namespace}"
        if Dir.exist?(folder)
          Dir.entries(folder).select { |f| f.end_with? '.json' }.map { |f| f.gsub('.json', '') }
        else
          []
        end
      end

      # Retrieves json data corresponding to the company with the specified permalink
      #
      # @param [Symbol,String] namespace The type of entity
      # @param [Symbol,String] permalink The permalink for this entity
      # @return [String] JSON data for the specified entity
      def self.fetch_entity(namespace, permalink)
        plural_namespace = namespace.to_s.pluralize
        File.open("#{Rails.root}/json_data/#{plural_namespace}/#{permalink}.json") { |f| f.read }
      end

      # Saves the JSON for the entity with the specified permalink within the specified namespace
      #
      # @param [Symbol, String] namespace the namespace for this entity
      # @param [Symbol, String] permalink the permalink for this entity
      # @param [String] json the data to be saved
      def self.save_entity(namespace, permalink, json)
        plural_namespace = namespace.to_s.pluralize

        # make local directory into which to save json, if needed
        unless Dir.exist?("#{Rails.root}/json_data/#{plural_namespace}")
          Dir.mkdir("#{Rails.root}/json_data") unless Dir.exist?("#{Rails.root}/json_data")
          Dir.mkdir("#{Rails.root}/json_data/#{plural_namespace}/")
        end

        # save to a file locally
        open("#{Rails.root}/json_data/#{plural_namespace}/#{permalink}.json", 'wb') do |f|
          f.write(json)
        end
      end

    end
  end
end
