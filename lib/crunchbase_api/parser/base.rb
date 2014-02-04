module ApiQueue
  module Parser
    # Converts the returned hash into a series of models.
    # The process_entity method decides how the input should be converted
    #
    # See existing code for how the models should be created.
    #
    # This will disable the class line length rubocop check. This is a temporary fix,
    # as this class is due for a refactor.
    # rubocop:disable ClassLength
    class Base

      def self.inherited(subclass)
        # create a threadsafe hash to store write mutexes
        subclass.instance_variable_set(:@mutexes, ThreadSafe::Hash.new)
      end

      class << self
        attr_reader :mutexes
      end

      # gets a mutex for a given class, lazily creates as needed
      #
      # @param [Class] klass the class for which a mutex is needed
      # @return [Mutex] the mutex for the specified class
      def self.get_mutex(klass)
        @mutexes[klass] ||= Mutex.new
      end

      # does a find_or_create_by in a threadsafe transaction to ensure no duplicates
      # are created, or errors caused by 2 threads trying to create the same entity
      #
      # @param [Class] klass the class for which you want to find or create
      # @param [Hash{String => String}] condition the attribute name and value to find/create by
      # @yield optional block containing attributes to assign/update
      # @yieldreturn [Hash] extra attributes to assign/update
      # @return [Person] the newly created person.
      def safe_find_or_create_by(klass, condition, &block)
        self.class.get_mutex(klass).synchronize do
          klass.transaction do
            entity = klass.find_or_create_by(condition)
            entity.update_attributes!(block.call) if block_given?
            entity
          end
        end
      end

      # Handles creating the objects for an individual entity
      # Must be overriden by the child class
      #
      # @param [Hash] entity_data the json data for the company to be parsed
      # @return [nil]
      def process_entity(entity_data)
        fail 'Parser::Base.process_entity must be overridden'
      end

      # Handles creating a company while ignoring extraneous keys.
      #
      # @param [Hash{String => String}] company_data A representation of the company. May contain extraneous keys.
      # @return [Company] the newly created company.
      def create_company(company_data)
        column_names = ::Company.column_names - ['id']
        attributes = company_data.select { |attribute| column_names.include?(attribute.to_s) }

        # I wouldn't normally do this but the linter passes
        %w(deadpooled founded).each do |type|
          attributes["#{type}_on".to_sym] = date_converter(
            company_data["#{type}_year"],
            company_data["#{type}_month"],
            company_data["#{type}_day"])
        end

        category_code = company_data['category_code']
        attributes[:category_id] = create_category(category_code).id if category_code
        safe_find_or_create_by(::Company, permalink: attributes['permalink']) { attributes }
      end

      # Handles creating an office location.
      #
      # @param [Hash{String => String}] office_location_data A representation of the office_location.
      #   May contain extraneous keys.
      # @return [OfficeLocation] the newly created company.
      def create_office_location(office_location_data, tenant)
        column_names = ::OfficeLocation.column_names
        attributes = office_location_data.select { |attribute| column_names.include?(attribute.to_s) }
        attributes[:tenant_id] = tenant.id
        attributes[:tenant_type] = tenant.class.to_s
        attributes[:latitude] &&= BigDecimal.new(attributes[:latitude])
        attributes[:longitude] &&= BigDecimal.new(attributes[:longitude])
        ::OfficeLocation.create!(attributes)
      end

      # Handles creating an acquisition.
      #
      # @param [Hash{String => String}] acquisition_data A representation of the acquisition.
      #   May contain extraneous keys.
      # @return [Acquisition] the newly created acquisition.
      def create_acquisition(acquisition_data, acquirer)
        column_names = ::Acquisition.column_names

        attributes = acquisition_data.select { |attribute| column_names.include?(attribute.to_s) }
        attributes[:acquired_on] = date_converter(
          acquisition_data['acquired_year'],
          acquisition_data['acquired_month'],
          acquisition_data['acquired_day'])
        attributes[:acquiring_company_id] = acquirer.id
        acquired_company = safe_find_or_create_by(
          ::Company,
          permalink: acquisition_data['company']['permalink']) { acquisition_data['company'] }
        attributes[:acquired_company_id] = acquired_company.id

        ::Acquisition.create!(attributes)
      end

      # Handles creating an ipo.
      #
      # @param [Hash{String => String}] ipo_data A representation of the ipo.
      #   May contain extraneous keys.
      # @return [InitialPublicOffering] the newly created ipo.
      def create_ipo(ipo_data, company)
        column_names = ::InitialPublicOffering.column_names
        attributes = ipo_data.select { |attribute| column_names.include?(attribute.to_s) }

        attributes[:offering_on] = date_converter(
          ipo_data['pub_year'],
          ipo_data['pub_month'],
          ipo_data['pub_day'])
        attributes[:company_id] = company.id

        ::InitialPublicOffering.create!(attributes)
      end

      # handles creation of categories. returns a new category if a null attr is passed
      # such that id can be called on the result safely regardless of input
      #
      # @param [String, nil] name the name of the category to be created, or nil
      # @return [Category] the newly created category
      def create_category(name)
        name.present? ? safe_find_or_create_by(::Category, name: name) : ::Category.new
      end

      # Handles creating a financial organization while ignoring extraneous keys.
      #
      # @param [Hash{String => String}] financial_org_data A representation of the financial organization.
      #   May contain extraneous keys.
      # @return [FinancialOrganization] the newly created financial organization
      def create_financial_org(financial_org_data)
        column_names = ::FinancialOrganization.column_names
        attributes = financial_org_data.select { |attribute| column_names.include?(attribute.to_s) }
        safe_find_or_create_by(::FinancialOrganization, permalink: attributes['permalink']) { attributes }
      end

      # Handles creating funding rounds for a company
      #
      # @param [Hash{String => String}] funding_round_data A representation of the funding round.
      # @param [Company] company The company with which to associate the funding round.
      # @return [FundingRound] the created funding round.
      def create_funding_round(funding_round_data, company)
        column_names = ::FundingRound.column_names
        attributes = funding_round_data.dup
        attributes[:raw_raised_amount] = BigDecimal.new(attributes.delete('raised_amount').to_s)
        attributes[:crunchbase_id] = attributes.delete('id')
        attributes[:company_id] = company.id

        attributes[:funded_on] = date_converter(
          funding_round_data['funded_year'],
          funding_round_data['funded_month'],
          funding_round_data['funded_day'])

        attributes = attributes.select { |attribute| column_names.include?(attribute.to_s) }
        safe_find_or_create_by(::FundingRound, crunchbase_id: attributes[:crunchbase_id]) { attributes }
      end

      # Handles creating an Investment relationship
      #
      # @param [Person, Company, FinancialOrganization] investor the investor
      # @param [Integer] funding_round_id The funding round id
      # @return [Investment] The Investment object
      def create_investment(investor, funding_round_id)
        ::Investment.create!(investor: investor, funding_round_id: funding_round_id)
      end

      # Handles creating a person
      #
      # @param [Hash{String => String}] parsed_person a hash representation of a person.
      # @return [Person] the newly created person.
      def create_person(parsed_person)
        # TODO: Write migration to rename 'firstname' and 'lastname' fields to match the crunchbase keys
        attributes = parsed_person.dup
        attributes['firstname'] = attributes.delete('first_name')
        attributes['lastname'] = attributes.delete('last_name')
        safe_find_or_create_by(::Person, permalink: attributes['permalink']) { attributes }
      end

      private

      # Converts dates and handles missing values
      # If year is set, month and day default to 1 if not set
      #
      # Important note: if passed a blank string, it will crash or give a bad output
      #
      # @param [Integer] year The year for the date
      # @param [Integer] month The month for the date
      # @param [Integer] day The day for the date
      # @return [Date] The given date with default values or nil if year isn't set
      def date_converter(year, month, day)
        if year
          month ||= 1
          day ||= 1
          Date.strptime("#{year}/#{month}/#{day}", '%Y/%m/%d')
        end
      end
    end
    # rubocop:enable ClassLength
  end
end
