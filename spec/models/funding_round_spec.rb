require 'spec_helper'

describe FundingRound do
  before(:each) do
    @funding_round = FundingRound.new
  end

  describe 'associations' do
    it { expect(@funding_round).to belong_to :company }
    it { expect(@funding_round).to have_many :investments }
  end

  describe 'validations' do
    it { expect(@funding_round).to validate_presence_of :crunchbase_id }
    it { expect(@funding_round).to validate_uniqueness_of :crunchbase_id }
  end

  describe 'fields' do
    it { expect(@funding_round).to respond_to :round_code }
    it { expect(@funding_round).to respond_to :source_url }
    it { expect(@funding_round).to respond_to :source_description }
    it { expect(@funding_round).to respond_to :raw_raised_amount }
    it { expect(@funding_round).to respond_to :raised_currency_code }
    it { expect(@funding_round).to respond_to :funded_on }
    it { expect(@funding_round).to respond_to :company_id }
    it { expect(@funding_round).to respond_to :crunchbase_id }
  end

  describe 'scopes' do
    describe 'for_companies' do
      before(:each) do
        company = FactoryGirl.create(:company)
        @company_ids = [company.id]
        @attached = FactoryGirl.create(:funding_round, company: company)
        @unattached = FactoryGirl.create(:funding_round)
      end

      it 'should return funding rounds attached to the given company ids' do
        expect(FundingRound.for_companies(@company_ids)).to include(@attached)
      end

      it 'should not return funding rounds that aren\'t attached' do
        expect(FundingRound.for_companies(@company_ids)).not_to include(@unattached)
      end
    end

    describe 'valid' do
      let(:company) { FactoryGirl.create(:valid_company) }
      let(:funding_round) { FactoryGirl.create(:invested_funding_round, company: company) }

      it 'should include funding rounds with valid companies' do
        expect(FundingRound.valid).to include(funding_round)
      end

      it 'should not include funding rounds with no valid companies' do
        company = FactoryGirl.create(:company)
        funding_round = FactoryGirl.create(:funding_round, company: company)
        expect(FundingRound.valid).not_to include(funding_round)
      end

      it 'should not include funding rounds with no companies' do
        funding_round = FactoryGirl.create(:funding_round, company: nil)
        expect(FundingRound.valid).not_to include(funding_round)
      end

      it 'should not include funding rounds with valid companies where the funding round is unfunded' do
        funding_round = FactoryGirl.create(:unfunded_funding_round, company: company)
        expect(FundingRound.valid).not_to include(funding_round)
      end
    end

    describe 'funded' do
      it 'should return funding rounds that have raised us dollars' do
        round = FactoryGirl.create(:funding_round)
        expect(FundingRound.funded).to include(round)
      end

      it 'should not return funding rounds that have raised a different kind of currency' do
        round = FactoryGirl.create(:funding_round, raised_currency_code: 'GBP')
        expect(FundingRound.funded).not_to include(round)
      end

      it 'should not return funding rounds whose raised amount is null' do
        round = FactoryGirl.create(:funding_round, raw_raised_amount: nil)
        expect(FundingRound.funded).not_to include(round)
      end

      it 'should not return funding rounds that have raised zero dollars' do
        round = FactoryGirl.create(:funding_round, raw_raised_amount: '0')
        expect(FundingRound.funded).not_to include(round)
      end
    end
  end

  describe 'instance methods' do
    before(:each) do
      @funding_round = FundingRound.new
    end

    describe 'raised_amount' do
      it 'should return the raw_raised_amount if raw_raised_amount is defined and raised_currency_code is \'USD\'' do
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
      it 'should return RawDecimal(0) if raised_currency_code is any value other than \'USD\'' do
        @funding_round.raw_raised_amount = BigDecimal.new('1234.56')
        @funding_round.raised_currency_code = 'LMNOP'

        expect(@funding_round.raised_amount).to eql(BigDecimal.new('0'))
      end
    end
  end
end
