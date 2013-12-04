require 'net/http'
require 'json/stream'

class Company < ActiveRecord::Base
  has_many :funding_rounds
  has_many :investments, as: :investor

  # Retrieves the list of companies Crunchbase has data for.
  #
  # @return [String] the list of companies.
  def self.get_all_companies
    Net::HTTP.start("api.crunchbase.com") do |http|
      resp = http.get("/v/1/companies.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
      resp.body
    end

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
      parsed_company["funding_rounds"].each do |fr|
        funding_round = FundingRound.create_funding_round(fr, company)
        fr["investments"].each do |inv|
          investor = nil
          if !inv["person"].nil?
            investor = Person.create_person(inv["person"])
          else
            puts inv["company"]["permalink"]
            investor = process_company({
              "permalink" => inv["company"]["permalink"]
            }, false)
          end
          Investment.create_investor(investor, funding_round.id, company)
        end
      end
    rescue Exception => e
      puts "Could not normalize data for #{parsed_company["name"]}"
      File.open("log/import.log", "w") do |f|
        f.write e
        f.write e.backtrace
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
      File.open("log/import.log", "w") do |f|
        f.write e.backtrace
      end
      return false
    end
  end

  # Handles creating a company
  #
  # @param [Hash{String => String}] a dictionary representation of a company.
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
end
