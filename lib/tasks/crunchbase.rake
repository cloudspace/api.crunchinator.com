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
    is_service = args.service.try(:downcase) == "s3" ? true : false
    companies = {}

    if is_service
      s3_service = S3::Service.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      crunchinator_bucket = s3_service.buckets.find("crunchinator.com")
      companies = crunchinator_bucket.objects
    else
      companies = JSON::Stream::Parser.parse(get_all_companies)
    end

    companies.each do |c|
      parsed_company = parse_company_info(c, is_service)
      create_company(parsed_company)
    end
  end
end

def parse_company_info(company, is_service)
  content = ""

  if is_service
    content = company.content
  else
    Net::HTTP.start("api.crunchbase.com") do |http|
      content = http.get("/v/1/company/#{company["permalink"]}.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}").body
    end
  end

  JSON::Stream::Parser.parse(content)
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
