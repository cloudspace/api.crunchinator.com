require 'zlib'
require 'stringio'
require 'json'

module ApiQueue
  module Source
    # An interface to interact with S3 buckets and retrieve JSON data for queue workers
    # as well as uploading data to S3.
    class S3
      BUCKET_NAME = 'crunchinator.com'

      # Retrieves the list of permalinks corresponding to entities for which there is data
      #   within the specified namespace.
      #
      # @param [Symbol,String] namespace The type of entity (company, person, etc)
      # @return [Array] the list of permalinks.
      def self.fetch_entities(namespace)
        prefix = namespace.to_s.pluralize + '/'
        bucket(BUCKET_NAME).objects.with_prefix(prefix).map { |obj| obj.key.gsub(prefix, '').gsub('.json', '') }
      end

      # Retrieves json data corresponding to the company with the specified permalink
      #
      # @param [Symbol,String] namespace The type of entity
      # @param [Symbol,String] permalink The permalink for this entity
      # @return [String] JSON data for the specified entity
      def self.fetch_entity(namespace, permalink)
        plural_namespace = namespace.to_s.pluralize
        bucket(BUCKET_NAME).objects["#{plural_namespace}/#{permalink}.json"].read
      end

      # Uploads the JSON for the entity with the specified permalink within the specified namespace to s3
      #
      # @param [Symbol, String] namespace the namespace for this entity
      # @param [Symbol, String] permalink the permalink for this entity
      # @param [String] json the data to be saved
      def self.save_entity(namespace, permalink, json)
        plural_namespace = namespace.to_s.pluralize
        file_name = "#{plural_namespace}/#{permalink}.json"
        upload_file(BUCKET_NAME, file_name, json)
      end

      # Uploads a file to s3
      #
      # @param [String] bucket_name the name of the bucket
      # @param [Symbol, String] file_name the filename to save the content as
      # @param [String] content the data to be saved
      def self.upload_file(bucket_name, file_name, content)
        new_object = bucket(bucket_name).objects[file_name]
        new_object.write(content)
        new_object
      end

      # Uploads a file to s3, sets acl to public, content_type to json
      #
      # @param [String] bucket_name the name of the bucket
      # @param [Symbol, String] file_name the filename to save the content as
      # @param [String] content the data to be saved
      def self.upload_and_expose(bucket_name, file_name, content)
        new_object = bucket(bucket_name).objects[file_name]
        new_object.write(gzip(content), acl: :public_read, content_type: 'json', content_encoding: 'gzip')
        new_object
      end

      # Empties the specified bucket
      #
      # @param [String] bucket_name the name of the bucket to empty
      def self.empty_bucket!(bucket_name)
        bucket(bucket_name).clear!
      end

      # Gets a bucket object corresponding to a specified name
      #
      # @param [String] bucket_name the name of the bucket
      # @return [AWS::S3::Bucket] the bucket object
      def self.bucket(bucket_name)
        service.buckets[bucket_name]
      end

      # Gets an authorized AWS::S3 object
      #
      # @return [AWS::S3] the S3 service object
      def self.service
        AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
      end

      private

      # Gzips a string
      #
      # @param [String] string the string to compress
      # @return [String] the compressed string
      def self.gzip(string)
        writer = StringIO.new('w')
        zipper = Zlib::GzipWriter.new(writer)
        zipper.write(string)
        zipper.close
        writer.string
      end

    end
  end
end
