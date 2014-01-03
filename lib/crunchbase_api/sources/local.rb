module ApiQueue
  module Source
    class Local

      def self.get_entities(namespace)
        plural_namespace = namespace.to_s.pluralize
        folder = "#{Rails.root}/json_data/#{plural_namespace}"
        Dir.exist?(folder) ? Dir.entries(folder).select{|f| f.end_with? '.json'}.map{|f| f.gsub('.json', '')} : []
      end

      def self.get_random_entities(namespace = :companies, n = 2000)
        get_entities(namespace).sample(n)
      end

      def self.get_entity(namespace, permalink)
        plural_namespace = namespace.to_s.pluralize
        # begin
          File.open("#{Rails.root}/json_data/#{plural_namespace}/#{permalink}.json"){|f| f.read}
        # rescue Errno::ENOENT => e
        #   false
        # end
      end

      def self.save_entity(namespace, permalink, json)
        plural_namespace = namespace.to_s.pluralize

        # make local directory into which to save json, if needed
        unless Dir.exist?("#{Rails.root}/json_data/#{plural_namespace}")
          unless Dir.exist?("#{Rails.root}/json_data")
            Dir.mkdir("#{Rails.root}/json_data")
          end
          Dir.mkdir("#{Rails.root}/json_data/#{plural_namespace}/")
        end

        # save to a file locally
        open("#{Rails.root}/json_data/#{plural_namespace}/#{permalink}.json", "wb") do |f|
          f.write(json)
        end
      end

    end
  end
end