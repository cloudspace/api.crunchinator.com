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
    describe 'create funding round' do
      it 'should create a new FundingRound'
      it 'should associate a new FundingRound with a company'
      it 'should return a new FundingRound'
    end
  end

  describe 'instance methods' do
    before(:each) do
      @funding_round = FundingRound.new
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
