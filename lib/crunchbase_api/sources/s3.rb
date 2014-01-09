require 'zlib'
require 'stringio'
require 'json'

module ApiQueue
  module Source
    class S3
      BUCKET_NAME = 'crunchinator.com'

      def self.get_all_entities
        bucket(BUCKET_NAME).objects.map { |obj| obj.key }
      end

      def self.get_entities(namespace)
        prefix = namespace.to_s.pluralize + '/'
        bucket(BUCKET_NAME).objects.with_prefix(prefix).map { |obj| obj.key.gsub(prefix, '').gsub('.json', '') }
      end

      def self.get_entity(namespace, permalink)
        plural_namespace = namespace.to_s.pluralize
        bucket(BUCKET_NAME).objects["#{plural_namespace}/#{permalink}.json"].read
      end

      # upload the json response to the S3 bucket
      def self.save_entity(namespace, permalink, json)
        plural_namespace = namespace.to_s.pluralize
        file_name = "#{plural_namespace}/#{permalink}.json"
        upload_file(BUCKET_NAME, file_name, json)
      end

      # uploads a file to s3
      def self.upload_file(bucket_name, file_name, content)
        new_object = bucket(bucket_name).objects[file_name]
        new_object.write(content)
        new_object
      end

      # uploads a file to s3m, sets acl to public, content_type to json
      def self.upload_and_expose(bucket_name, file_name, content)
        new_object = bucket(bucket_name).objects[file_name]
        new_object.write(gzip(content), acl: :public_read, content_type: 'json', content_encoding: 'gzip')
        new_object
      end

      def self.empty_bucket!(bucket_name)
        bucket(bucket_name).clear!
      end

      def self.bucket(bucket_name)
        service.buckets[bucket_name]
      end

      def self.service
        AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
      end

      private

      def self.gzip(string)
        wio = StringIO.new('w')
        w_gz = Zlib::GzipWriter.new(wio)
        w_gz.write(string)
        w_gz.close
        wio.string
      end

    end
  end
end
