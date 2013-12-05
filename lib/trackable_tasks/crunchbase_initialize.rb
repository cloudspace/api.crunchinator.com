require 's3'
require 'json/stream'

class CrunchbaseInitialize < TrackableTasks::Base
  def initialize(service = nil, log_level = :notice)
    @service = service
    super log_level
  end

  def run
    is_service = @service.try(:downcase) == "s3" ? true : false
    companies = {}

    if is_service
      puts "Fetching Objects from Bucket..."
      s3_service = S3::Service.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      crunchinator_bucket = s3_service.buckets.find("crunchinator.com")
      companies = crunchinator_bucket.objects
    else
      companies = JSON::Stream::Parser.parse(Company.get_all_companies)
    end

    companies.each do |company|
      Company.process_company(company,is_service)
    end
  end
end
