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
      puts "Fetching Objects from Bucket..."
      s3_service = S3::Service.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      crunchinator_bucket = s3_service.buckets.find("crunchinator.com")
      companies = crunchinator_bucket.objects
    else
      companies = JSON::Stream::Parser.parse(get_all_companies)
    end

    companies.each do |company|
      process_company(company,is_service)
    end
  end
  
  desc "Retrieve and save a single company based on permalink"
  task :company, [:permalink] => :environment do |t, args|
    company = {
      "permalink" => args.permalink
    }
    is_service = false
    process_company(company,is_service)
  end
end


# Handles creating the objects for an individual company
#
# @param [String] company the company to be parsed
# @param [Boolean] is_service whether we are using the s3 service
# @return nil
def process_company(company, is_service)
  parsed_company = parse_company_info(company, is_service)
  return unless parsed_company
  puts "Normalizing data for #{parsed_company['name']}"
  begin
    company = create_company(parsed_company)
    parsed_company["funding_rounds"].each do |fr|
      fr["investments"].each do |inv|
        create_person(inv["person"]) unless inv["person"].nil?
      end
      create_funding_round(fr, company)
    end
  rescue Exception => e
    puts "Could not normalize data for #{parsed_company["name"]}"
    File.open("log/import.log", "w") do |f|
      f.write e
    end
  end
end


def parse_company_info(company, is_service)
  content = ""

  if is_service
    content = company.content
  else
    Net::HTTP.start("api.crunchbase.com") do |http|
      # TODO:  This does not account for redirection, make it work with redirects
      response = http.get("/v/1/company/#{company["permalink"]}.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
      content = response.body
      if(response.code != "200")
        return false;
      end
    end
  end
  # There is no utf-8 representation of an ASCII record seperator, which causes the
  # json serializer to be sad. The code:
  #     gsub(/[[:cntrl:]]/, '')
  # replaces this unidentified character.
  #
  begin
    JSON::Stream::Parser.parse(content.gsub(/[[:cntrl:]]/, ''))
  rescue Exception => e
    File.open("log/import.log", "w") do |f|
      f.write e
    end
    return false
  end
end

# Retrieves the list of companies Crunchbase has data for.
#
# @return [String] the list of companies.
def get_all_companies
  Net::HTTP.start("api.crunchbase.com") do |http|
    resp = http.get("/v/1/companies.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
    resp.body
  end
end

# Handles creating funding rounds for a company
#
# @param [Hash{String => String}] a dictionary representation of a funding round.
# @param [Company] the company to associate the funding round with.
# @return [FundingRound] the created funding round.
def create_funding_round(parsed_funding_round, company)
  dup = parsed_funding_round.clone
  dup.delete_if {|key| !FundingRound.column_names.include? key }
  dup[:company_id] = company.id
  FundingRound.create(dup)
end

# Handles creating a person
#
# @param [Hash{String => String}] a dictionary representation of a person.
# @return [Person] the newly created person.
def create_person(parsed_person)
  # TODO: Write migration to rename 'firstname' and 'lastname' fields to match the
  # crunchbase keys
  #
  Person.new(firstname: parsed_person["first_name"], lastname: parsed_person["last_name"], permalink: parsed_person["permalink"]).save
end

# Handles creating a company
#
# @param [Hash{String => String}] a dictionary representation of a company.
# @return [Person] the newly created company.
def create_company(parsed_company)
  dup = parsed_company.clone
  dup.delete_if {|key| !Company.column_names.include? key }
  Company.create(dup) if !dup["category_code"].nil?
end
