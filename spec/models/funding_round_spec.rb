require 'spec_helper'

describe FundingRound do
  describe "associations" do
    before(:each) do
      @funding_round = FundingRound.new
    end
    subject { @funding_round }
    
    it { should belong_to :company }
    it { should have_many :investments }
  end
  
  describe "validations" do
    it { should validate_presence_of :crunchbase_id }
    it { should validate_uniqueness_of :crunchbase_id }
  end
  
  describe "fields" do
    it { should respond_to :round_code }
    it { should respond_to :source_url }
    it { should respond_to :source_description}
    it { should respond_to :raw_raised_amount }
    it { should respond_to :raised_currency_code }
    it { should respond_to :funded_year }
    it { should respond_to :funded_month }
    it { should respond_to :funded_day }
    it { should respond_to :company_id }
    it { should respond_to :crunchbase_id }
  end
  
  describe 'scopes' do
    describe "for_companies" do
      before(:each) do
        company = FactoryGirl.create(:company)
        @company_ids = [company.id]
        @attached = FactoryGirl.create(:funding_round, :company => company)
        @unattached = FactoryGirl.create(:funding_round)
      end

      it "should return funding rounds attached to the given company ids" do
        expect(FundingRound.for_companies(@company_ids)).to include(@attached)
      end

      it "should not return funding rounds that aren't attached" do
        expect(FundingRound.for_companies(@company_ids)).not_to include(@unattached)
      end
    end

    describe "valid" do
      it "needs tests"
    end
  end

  describe 'instance methods' do
    before(:each) do
      @funding_round = FundingRound.new
    end

    describe 'raised_amount' do
      it 'should return the raw_raised_amount if raw_raised_amount is defined and raised_currency_code is "USD"' do
        @funding_round.raw_raised_amount = BigDecimal.new('1234.56')
        @funding_round.raised_currency_code = 'USD'

        expect(@funding_round.raised_amount).to eql(BigDecimal.new('1234.56'))
      end
      it 'should return RawDecimal(0) if raw_raised_amount is nil' do
        @funding_round.raw_raised_amount = nil
        @funding_round.raised_currency_code = 'USD'

        expect(@funding_round.raised_amount).to eql(BigDecimal.new('0'))
      end
      it 'should return RawDecimal(0) if raised_currency_code is nil' do
        @funding_round.raw_raised_amount = BigDecimal.new('1234.56')
        @funding_round.raised_currency_code = nil

        expect(@funding_round.raised_amount).to eql(BigDecimal.new('0'))
      end
      it 'should return RawDecimal(0) if raised_currency_code is any value other than "USD"' do
        @funding_round.raw_raised_amount = BigDecimal.new('1234.56')
        @funding_round.raised_currency_code = 'LMNOP'

        expect(@funding_round.raised_amount).to eql(BigDecimal.new('0'))
      end
    end

    describe 'funded_on' do
      it 'should return a date' do
        @funding_round.funded_year = 2013
        @funding_round.funded_month = 1
        @funding_round.funded_day = 1

        expect(@funding_round.funded_on).to eql(Date.parse('2013-1-1'))
      end
    end
  end
end
