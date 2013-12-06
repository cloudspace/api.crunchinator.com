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
  
  describe 'class methods' do
    describe 'create_funding_round' do
      it 'should create a new FundingRound'
      it 'should associate a new FundingRound with a company'
      it 'should return a new FundingRound'
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
