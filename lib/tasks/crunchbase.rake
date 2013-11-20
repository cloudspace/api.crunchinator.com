require 's3'
require 'json/stream'
require 'net/http'

namespace :crunchbase do
  desc "Retrieve and save crunchbase company index"
  task :company_list => :environment do
    puts get_all_companies
  end

  desc "Retrieve and save crunchbase company details"
  task :init, [:service] => :environment do |t, args|
    if args.service.try(:downcase) != "s3"
      companies = JSON::Stream::Parser.parse(get_all_companies)

      companies.each do |c|
        Net::HTTP.start("api.crunchbase.com") do |http|
          resp = http.get("/v/1/company/#{c["permalink"]}.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
          parsed_company = JSON::Stream::Parser.parse(resp.body)
          create_company(parsed_company)
        end
      end
    else
      s3_service = S3::Service.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      crunchinator_bucket = s3_service.buckets.find("crunchinator.com")
      crunchinator_bucket.objects.each do |c|
        parsed_company = JSON::Stream::Parser.parse(c.content)
        create_company(parsed_company)
      end
    end
  end
end

def get_all_companies
  Net::HTTP.start("api.crunchbase.com") do |http|
    resp = http.get("/v/1/companies.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
    resp.body
  end
end

def create_company(parsed_company)
  parsed_company.delete_if {|key| !Company.column_names.include? key }
  Company.create(parsed_company) if !parsed_company["category_code"].nil?
end
