require 'spec_helper'

# the parser base class does not run on it's own
# it functions as an abstract class
class ParserSubclass < ApiQueue::Parser::Base; end

describe ApiQueue::Parser::Base do
  describe 'class methods' do
    describe 'inherited' do
      it 'should create a threadsafe mutexes hash when subclassed' do
        ParserSubclass.instance_variables.should include(:@mutexes)
      end
    end
  end

  describe 'instance methods' do
    before(:each) do
      @parser = ParserSubclass.new
    end

    describe 'safe_find_or_create_by' do
      it 'should get the object and update it\'s attributes' do
        person = Person.new
        conditions = { permalink: 'john-123' }
        attributes = {
          first_name: 'john',
          last_name: 'smith'
        }

        ::Person.should_receive(:find_or_create_by).with(conditions).and_return(person)
        person.should_receive(:update_attributes!).with(attributes).and_return(person)

        output = @parser.safe_find_or_create_by(::Person, conditions) { attributes }
        expect(output).to eq(person)
      end
    end

    describe 'process_entity' do
      it 'should throw an error unless overridden' do
        expect { @parser.process_entity }.to raise_error
      end
    end

    describe 'create_company' do
      before(:each) do
        @attributes = {
          'permalink' => 'company-1',
          'category_code' => 'category-1'
        }

        @parser.stub(:create_category).and_return(::Category.new)
        @parser.stub(:date_converter)
        @parser.stub(:safe_find_or_create_by)
      end

      it 'should create a category if one is provided' do
        @parser.should_receive(:create_category).and_return(::Category.new)
        @parser.create_company(@attributes)
      end

      it 'should not create a category if none is provided' do
        @attributes.delete('category_code')
        @parser.should_not_receive(:create_category)
        @parser.create_company(@attributes)
      end

      it 'should find or create a company based on the permalink' do
        @parser.should_receive(:safe_find_or_create_by).with(::Company, permalink: 'company-1')
        @parser.create_company(@attributes)
      end

      it 'should use the date_converter to get the deadpooled date' do
        attributes = @attributes.merge(
          'deadpooled_year' => 2014,
          'deadpooled_month' => 1,
          'deadpooled_day' => 27)
        @parser.should_receive(:date_converter).with(2014, 1, 27)
        @parser.create_company(attributes)
      end

      it 'should use the date_converter to get the founded date' do
        attributes = @attributes.merge(
          'founded_year' => 2013,
          'founded_month' => 2,
          'founded_day' => 30)
        @parser.should_receive(:date_converter).with(2013, 2, 30)
        @parser.create_company(attributes)
      end
    end

    describe 'create_office_location' do
      it 'should create an office location' do
        tenant = Person.new

        ::OfficeLocation.should_receive(:create!)
        @parser.create_office_location({}, tenant)
      end
    end

    describe 'create_acquisition' do
      before(:each) do
        @attributes = {
          'acquired_year' => 2014,
          'acquired_month' => 1,
          'acquired_day' => 27,
          'company' => { 'permalink' => 'Cloudspace' }
        }
        @acquirer = Company.new
        ::Acquisition.stub(:create!)
        @parser.stub(:safe_find_or_create_by).and_return(Company.new)
      end

      it 'should create an acquisition' do
        ::Acquisition.should_receive(:create!)
        @parser.create_acquisition(@attributes, @acquirer)
      end

      it 'should find or create the acquired company' do
        @parser.should_receive(:safe_find_or_create_by).with(::Company, permalink: 'Cloudspace')
        @parser.create_acquisition(@attributes, @acquirer)
      end

      it 'should use the date_converter to get the date' do
        @parser.should_receive(:date_converter).with(2014, 1, 27)
        @parser.create_acquisition(@attributes, @acquirer)
      end
    end

    describe 'create_ipo' do
      it 'needs comments'
      it 'needs comments for the acuqistion method'
      it 'should create an ipo'
      it 'should set the date'
    end

    describe 'create_category' do
      it 'should try to find a category if a name is given' do
        @parser.should_receive(:safe_find_or_create_by).with(::Category, name: 'a category')
        @parser.create_category('a category')
      end

      it 'should return a new record if no name is given' do
        ::Category.should_receive(:new)
        @parser.create_category(nil)
      end
    end

    describe 'create_financial_org' do
      it 'should find or create a financial organization by permalink' do
        attributes = {
          'permalink' => 'org-123'
        }
        @parser.should_receive(:safe_find_or_create_by).with(::FinancialOrganization, permalink: 'org-123')
        @parser.create_financial_org(attributes)
      end
    end

    describe 'create_funding_round' do
      before(:each) do
        @attributes = {
          'id' => '12345',
          'funded_year' => 2014,
          'funded_month' => 1,
          'funded_day' => 27
        }
        @parser.stub(:date_converter)
        @parser.stub(:safe_find_or_create_by)

        @company = ::Company.new
      end

      it 'should find or create a funding round by crunchbase_id' do
        @parser.should_receive(:safe_find_or_create_by).with(::FundingRound, crunchbase_id: '12345')
        @parser.create_funding_round(@attributes, @company)
      end

      it 'should use the date_converter to get the date' do
        @parser.should_receive(:date_converter).with(2014, 1, 27)
        @parser.create_funding_round(@attributes, @company)
      end
    end

    describe 'create_investment' do
      it 'should call the investor create method' do
        investor = { id: 1 }
        funding_round_id = 2
        ::Investment.stub(:create!)# .with({investor: investor, funding_round_id: funding_round_id})
        @parser.create_investment(investor, funding_round_id)
      end
    end

    describe 'create_person' do
      before(:each) do
        @attributes = {
          'first_name' => 'john',
          'last_name' => 'smith',
          'permalink' => 'john_smith_123'
        }
      end

      it 'should find or create a person based on the permalnk' do
        @parser.stub(:safe_find_or_create_by).with(::Person, permalink: 'john_smith_123')
        @parser.create_person(@attributes)
      end
    end

    describe 'date_converter' do
      it 'should return a date object if all parameters are set' do
        expect(@parser.send(:date_converter, 2014, 2, 27)).to eq(Date.parse('2014/2/27'))
      end

      it 'should return a date object with defaults if year is set but month and date are not' do
        expect(@parser.send(:date_converter, 2014, nil, nil)).to eq(Date.parse('2014/1/1'))
      end

      it 'should be able to handle missing leading zeroes on the month and day' do
        expect(@parser.send(:date_converter, 2014, '02', '02')).to eq(Date.parse('2014/2/2'))
      end

      it 'should return nil if the year isn\'t set' do
        expect(@parser.send(:date_converter, nil, 2, 2)).to be_nil
      end
    end
  end
end
