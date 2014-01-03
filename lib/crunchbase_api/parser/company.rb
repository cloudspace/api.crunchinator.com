module ApiQueue
  module Parser
    class Company < ApiQueue::Parser::Base
      # Handles creating the objects for an individual company
      #
      # @param [Hash] company_data the json data for the company to be parsed
      # @return [nil]
      def self.process_entity(company_data)
        puts "Normalizing data for #{company_data['name']}"
        if company_data['category_code']
          company = create_company(company_data)
          company_data['funding_rounds'].each do |fr|
            funding_round = create_funding_round(fr, company)
            if fr['investments'].present?
              funding_round.investments.destroy_all
              fr['investments'].each do |investment|
                investor = if !investment['person'].nil?
                  create_person(investment['person'])
                elsif !investment['company'].nil?
                  create_company(investment['company'])
                elsif !investment['financial_org'].nil?
                  create_financial_org(investment['financial_org'])
                else
                  raise "Unknown investment type! - #{inves†ment.inspect}"
                end
                create_investment(investor, funding_round.id) if investor
              end
            end
          end
          if company_data['offices'].present?
            company.office_locations.destroy_all
            company_data['offices'].each_with_index do |office_data, index|
              hq_data = (index == 0 ? {headquarters: true} : {})
              create_office_location(office_data.merge(hq_data), company)
            end
          end
        end
      end
    end
  end
end
