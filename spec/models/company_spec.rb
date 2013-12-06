require 'spec_helper'

describe Company do
  describe "associations" do
    before(:each) do
      @company = Company.new
    end
    subject { @company }
  
    it { should have_many :funding_rounds }
    it { should have_many :investments }
  end

  describe 'class methods' do
    describe 'get_all_companies' do
      it 'should return a json list of companies'
    end

    describe 'process_company' do
      it 'should create a company'
      it 'should build funding rounds for specified company'
      it 'should build investments for funding rounds'
      it 'should build investors for investments'
      it 'should write to logfile [log/import.log] if unable to normalize'
    end

    describe 'parse_company_info' do
      it 'should return newly created Company if successful'
      it 'should return nil if Company object could not be created'
    end
  end

  describe 'instance methods' do
    before(:each) do
      @company = Company.new
    end

    describe 'total_funding' do
      it 'should return 0 if there are no funding rounds' do
        expect(@company.total_funding).to eql(0)
      end

      it 'should return the sum of the funding rounds raised amount' do
        # wow rails, you so great
        funding_round1 = FundingRound.new(:raw_raised_amount => BigDecimal.new('1000'), :raised_currency_code => 'USD')
        funding_round2 = FundingRound.new(:raw_raised_amount => BigDecimal.new('2000'), :raised_currency_code => 'USD')

        @company.stub(:funding_rounds).and_return([funding_round1, funding_round2])
        expect(@company.total_funding).to eql(BigDecimal.new('3000'))
      end
    end
  end
end
