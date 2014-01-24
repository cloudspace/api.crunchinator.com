require 'spec_helper'

describe ApiQueue::Parser::Company do

  describe 'integration tests' do
    before(:all) do
      # note manual database cleaning due to before all.  Running parser once saves a bunch of time.
      DatabaseCleaner.start
      @response = JSON.parse(IO.read(Rails.root.to_s + '/spec/fixtures/company_endpoint_response.json'))
      @parser = ApiQueue::Parser::Company.new
      @parser.process_entity(@response)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'should create a company identifiable by name or permalink' do
      expect(Company.where(name: @response['name']).count).to eq(1)
      expect(Company.where(permalink: @response['permalink']).count).to eq(1)
    end

    it 'should create a funding round for each record in the response' do
      @response['funding_rounds'].each do |funding_round|
        expect(FundingRound.where(crunchbase_id: funding_round['id']).size).to eq(1)
        fr = FundingRound.where(crunchbase_id: funding_round['id']).first
        expect(fr.funded_on).to eq(
          Date.parse("#{funding_round['funded_year']}/#{funding_round['funded_month']}/#{funding_round['funded_day']}")
        )
      end
    end

    it 'should create an investment and an investor for each record in the response' do
      # company = Company.where(permalink: @response['permalink']).first

      @response['funding_rounds'].each do |funding_round|

        funding_round_instance = FundingRound.where(crunchbase_id: funding_round['id']).first
        investor = nil

        funding_round['investments'].each do |investment|
          if investment['company'].is_a? Hash
            investor = Company.where(permalink: investment['company']['permalink']).first
          elsif investment['financial_org'].is_a? Hash
            investor = FinancialOrganization.where(permalink: investment['financial_org']['permalink']).first
          elsif investment['person'].is_a? Hash
            investor = Person.where(permalink: investment['person']['permalink']).first
          end
          expect(investor).to be_present
          expect(Investment.where(investor: investor, funding_round_id: funding_round_instance.id).size).to eq(1)
        end
      end
    end

    it 'should create offices for each record in the response' do
      company = Company.where(permalink: @response['permalink']).first

      @response['offices'].each do |office|
        # offices don't really have a unique key so faking it for now
        expect(OfficeLocation.where(tenant: company, address1: office['address1']).size).to eq(1)
      end
    end

    it 'api endpint data where one of the records fails validation' do
      expect { @parser.process_entity('name' => 'Cloudspace', 'category_code' => 'Unknown') }.to raise_error
      expect(Company.where(permalink: 'Cloudspace').count).to eq(0)
    end

    it 'when running the same data twice, it should not duplicate model instances' do
      expect(Company.where(permalink: @response['permalink']).count).to eq(1)
      @parser.process_entity(@response)
      expect(Company.where(permalink: @response['permalink']).count).to eq(1)
    end
  end

  describe 'instance methods' do
    before(:each) do
      @parser = ApiQueue::Parser::Company.new
    end
    describe 'process_entity' do
      before(:each) do
        @attributes = {
          'category_code' => '123'
        }

        @parser.stub(:create_company)
        @parser.stub(:process_funding_rounds)
        @parser.stub(:process_offices)
      end

      it 'should do nothing if there is no category code in the input' do
        @parser.should_not_receive(:create_company)
        @parser.process_entity({})
      end

      it 'should create a company' do
        @parser.should_receive(:create_company).with(@attributes)
        @parser.process_entity(@attributes)
      end

      it 'should process funding rounds' do
        @parser.should_receive(:process_funding_rounds)
        @parser.process_entity(@attributes)
      end

      it 'should process offices' do
        @parser.should_receive(:process_offices)
        @parser.process_entity(@attributes)
      end
    end

    describe 'process_fuding_rounds' do
      before(:each) do
        @attributes = {
          'funding_rounds' => [
            {
              'investments' => [
                {
                  'person' => {}
                }
              ]
            }
          ]
        }
        @parser.instance_variable_set(:@entity_data, @attributes)
        @company = ::Company.new
        @parser.instance_variable_set(:@company, @company)

        @parser.stub(:create_funding_round).and_return(::FundingRound.new)
        @parser.stub(:create_person)
        @parser.stub(:create_investment)
      end

      it 'should create a funding round' do
        @parser.should_receive(:create_funding_round)
          .with(@attributes['funding_rounds'].first, @company)
          .and_return(::FundingRound.new)
        @parser.send(:process_funding_rounds)
      end

      it 'should destroy all existing investments for the company' do
        funding_round = ::FundingRound.new
        @parser.stub(:create_funding_round).and_return(funding_round)
        funding_round.investments.should_receive(:destroy_all)
        @parser.send(:process_funding_rounds)
      end

      it 'should create new investors' do
        @parser.should_receive(:create_person).with(@attributes['funding_rounds'][0]['investments'][0]['person'])
        @parser.send(:process_funding_rounds)
      end

      it 'should create new investments' do
        person = ::Person.new
        @parser.stub(:create_person).and_return(person)
        @parser.should_receive(:create_investment).with(person, nil)
        @parser.send(:process_funding_rounds)
      end
    end

    describe 'process_offices' do
      before(:each) do
        @attributes = {
          'offices' => [
            { 'api_data' => '123' }
          ]
        }
        @parser.instance_variable_set(:@entity_data, @attributes)
        @company = ::Company.new
        @parser.instance_variable_set(:@company, @company)

        @parser.stub(:create_office_location)
      end

      it 'should destroy all existing offices for the company' do
        @company.office_locations.should_receive(:destroy_all)
        @parser.send(:process_offices)
      end

      it 'should create new office locations' do
        @parser.should_receive(:create_office_location).with({ 'api_data' => '123', headquarters: true }, @company)
        @parser.send(:process_offices)
      end
    end
  end
end
