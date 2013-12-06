require 'net/http'
require 'json/stream'

class Company < ActiveRecord::Base
  has_many :funding_rounds
  has_many :investments, :as => :investor

  validates :name, :uniqueness => true
  validates :permalink, :uniqueness => true

  # Retrieves the list of companies Crunchbase has data for.
  #
  # @return [Hash] the list of companies.
  def self.get_all_companies
    resp = ""
    Net::HTTP.start("api.crunchbase.com") do |http|
      resp = http.get("/v/1/companies.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
      resp.body
    end

    JSON::Stream::Parser.parse(resp.body)
  end

  # Handles creating the objects for an individual company
  #
  # @param [String] company the company to be parsed
  # @param [Boolean] is_service whether we are using the s3 service
  # @return nil
  def self.process_company(company, is_service)
    parsed_company = parse_company_info(company, is_service)
    return unless parsed_company
    puts "Normalizing data for #{parsed_company['name']}"
    begin
      company = create_company(parsed_company)
      if company
        parsed_company["funding_rounds"].each do |fr|
          funding_round = FundingRound.create_funding_round(fr, company)
          fr["investments"].each do |inv|
            investor = nil
            if !inv["person"].nil?
              investor = Person.create_person(inv["person"])
            elsif !inv["company"].nil?
              investor = self.create({name: inv["company"]["name"], permalink: inv["company"]["permalink"]})
            end
            Investment.create_investor(investor, funding_round.id, company) unless investor.nil?
          end
        end
      else
        puts "No category_code for #{parsed_company['name']}, skipping"
      end
    rescue Exception => e
      puts "Could not normalize data for #{parsed_company["name"]}"
      File.open("log/import.log", "a") do |f|
        f.write e + "\n"
        e.backtrace.each{|line| f.write line + "\n"}
        f.write "-----------------------------------------------------------------------------------------\n"
      end
    end
  end

  # Handles parsing the data for a single company
  #
  # @param [Company, Hash<String, String>] the company we need to parse
  # @param [Boolean] whether we are using a service or not
  # @return nil
  def self.parse_company_info(company, is_service)
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
      puts "Could not parse company info for #{company.inspect}"
      File.open("log/import.log", "a") do |f|
        f.write e + "\n"
        f.write "Company: #{company.inspect}\n"
        f.write "Content: #{content.inspect}\n"
        e.backtrace.each{|line| f.write line + "\n"}
        f.write "-----------------------------------------------------------------------------------------\n"
      end
      return false
    end
  end

  # Handles creating a company while ignoring extraneous keys.
  #
  # @param [Hash{String => String}] a hash representation of a company. May contain extraneous keys.
  # @return [Person] the newly created company.
  def self.create_company(parsed_company)
    dup = parsed_company.clone
    dup.delete_if {|key| !self.column_names.include? key }
    
    if !dup["category_code"].nil?
      company = self.find_or_create_by_permalink(dup["permalink"])
      company.update_attributes(dup)
      return company
    end
  end

  # place holder for the zip code until we get the office/headquarter system inplace
  # TODO: remove this and replace all references with a company.headquarters.zip_code call (JH 12-4-2013)
  def zip_code
    "32817"
  end

  # Concerned about how slow this will be
  # this is only needed for the front end and it has all of the data to caluclate it
  # may need to denormalize the value or let the front end calculate it on it's own
  def total_funding
    funding_rounds.to_a.sum { |fr| fr.raised_amount }
  end
end
