module ApiQueue
  module Parser
    class Company < ApiQueue::Parser::Base
      # Handles creating the objects for an individual company
      #
      # @param [Hash] entity_data the json data for the company to be parsed
      # @return [nil]
      def process_entity(entity_data)
        @entity_data = entity_data
        Rails.logger.info "Normalizing data for #{@entity_data['name']}"
        if @entity_data['category_code']
          @company = create_company(@entity_data)
          process_funding_rounds
          process_offices
        end
      end

      private

      # Handles creating the objects for the funding_rounds on the current company
      def process_funding_rounds
        @entity_data['funding_rounds'].each do |funding_round_data|
          funding_round = create_funding_round(fr, @company)
          if funding_round_data['investments'].present?
            funding_round.investments.destroy_all
            funding_round_data['investments'].each do |investment|
              investor = nil
              %w[person company financial_org].each do |investor_type|
                if investment[investor_type]
                  investor = send("create_#{investor_type}".to_sym, investment[investor_type])
                end
              end
              create_investment(investor, funding_round.id) if investor
            end
          end
        end
      end

      # Handles creating the office locations current company
      def process_offices
        if @entity_data['offices'].present?
          @company.office_locations.destroy_all
          @entity_data['offices'].each_with_index do |office_data, index|
            hq_data = (index == 0 ? { headquarters: true } : {})
            create_office_location(office_data.merge(hq_data), @company)
          end
        end
      end
    end
  end
end
