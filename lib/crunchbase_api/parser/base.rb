module ApiQueue
  module Parser
    # Converts the returned hash into a series of models.
    # The process_entity method decides how the input should be converted
    #
    # See existing code for how the models should be created.
    #
    # There are additional tickets to complete the ApiParser.
    class Base

      def self.inherited(subclass)
        # create a threadsafe hash to store write mutexes
        subclass.instance_variable_set(:@mutexes, ThreadSafe::Hash.new)
      end

      # an accessor for the mutexes hash
      #
      # @return [Hash{FixNum => Mutex}] the class-level mutex store
      def self.mutexes
        @mutexes
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
      def self.safe_find_or_create_by(klass, condition)
        get_mutex(klass).synchronize do
          klass.transaction do
            entity = klass.find_or_create_by(condition)
            entity.update_attributes(yield) if block_given?
            entity
          end
        end
      end

      # Handles creating the objects for an individual entity
      # Must be overriden by the child class
      #
      # @param [Hash] entity_data the json data for the company to be parsed
      # @return [nil]
      def self.process_entity(entity_data)
        raise "Parser::Base.process_entity must be overridden"
      end

      # Handles creating a company while ignoring extraneous keys.
      #
      # @param [Hash{String => String}] company_data A representation of the company. May contain extraneous keys.
      # @return [Company] the newly created company.
      def self.create_company(company_data)
        category = create_category(company_data['category_code'])
        column_names = ::Company.column_names - ["id"]
        attributes = company_data.select{ |attribute| column_names.include?(attribute.to_s) }
        attributes[:category_id] = category.id
        safe_find_or_create_by(::Company, permalink: attributes['permalink']){ attributes }
      end

      # Handles creating an office location.
      #
      # @param [Hash{String => String}] office_location_data A representation of the office_location. May contain extraneous keys.
      # @return [OfficeLocation] the newly created company.
      def self.create_office_location(office_location_data, tenant)
        column_names = ::OfficeLocation.column_names
        attributes = office_location_data.select{ |attribute| column_names.include?(attribute.to_s) }
        attributes[:tenant_id] = tenant.id
        attributes[:tenant_type] = tenant.class.to_s
        attributes[:latitude] &&= BigDecimal.new(attributes[:latitude])
        attributes[:longitude] &&= BigDecimal.new(attributes[:longitude])
        ::OfficeLocation.create(attributes)
      end

      # handles creation of categories. returns a new category if a null attr is passed
      # such that id can be called on the result safely regardless of input
      #
      # @param [String, nil] name the name of the category to be created, or nil
      # @return [Category] the newly created category
      def self.create_category(name)
        name.present? ? safe_find_or_create_by(::Category, name: name) : ::Category.new
      end
      
      # Handles creating a financial organization while ignoring extraneous keys.
      #
      # @param [Hash{String => String}] financial_org_data A representation of the financial organization. May contain extraneous keys.
      # @return [FinancialOrganization] the newly created financial organization
      def self.create_financial_org(financial_org_data)
        column_names = ::FinancialOrganization.column_names
        attributes = financial_org_data.select{ |attribute| column_names.include?(attribute.to_s) }
        safe_find_or_create_by(::FinancialOrganization, permalink: attributes['permalink']){ attributes }
      end

      # Handles creating funding rounds for a company
      #
      # @param [Hash{String => String}] funding_round_data A representation of the funding round.
      # @param [Company] company The company with which to associate the funding round.
      # @return [FundingRound] the created funding round.
      def self.create_funding_round(funding_round_data, company)
        column_names = ::FundingRound.column_names
        attributes = funding_round_data.dup
        attributes[:raw_raised_amount] = BigDecimal.new(attributes.delete('raised_amount').to_s)
        attributes[:crunchbase_id] = attributes.delete('id')
        attributes[:company_id] = company.id
        attributes = attributes.select{ |attribute| column_names.include?(attribute.to_s) }
        safe_find_or_create_by(::FundingRound, crunchbase_id: attributes[:crunchbase_id]){ attributes }
      end

      # Handles creating an Investment relationship
      #
      # @param [Person, Company, FinancialOrganization] investor the investor
      # @param [Integer] funding_round_id The funding round id
      # @return [Investment] The Investment object
      def self.create_investment(investor, funding_round_id)
        ::Investment.create(investor: investor, funding_round_id: funding_round_id)
      end

      # Handles creating a person
      #
      # @param [Hash{String => String}] parsed_person a hash representation of a person.
      # @return [Person] the newly created person.
      def self.create_person(parsed_person)
        # TODO: Write migration to rename 'firstname' and 'lastname' fields to match the crunchbase keys
        attributes = parsed_person.dup
        attributes['firstname'] = attributes.delete('first_name')
        attributes['lastname'] = attributes.delete('last_name')
        safe_find_or_create_by(::Person, permalink: attributes['permalink']){ attributes }
      end
    end
  end
end
