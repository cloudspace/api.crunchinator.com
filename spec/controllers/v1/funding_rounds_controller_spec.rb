require 'spec_helper'

describe V1::FundingRoundsController do
  describe 'index' do

    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate responses' do
      before(:each) do
        company = FactoryGirl.create(:legit_company_with_investors)
        @funding_round = company.funding_rounds.first # FactoryGirl.create(:invested_funding_round, company: @company)
        investment = @funding_round.investments.first
        @investor = investment.investor
      end

      it 'includes legit funding rounds' do
        get :index

        funding_round = JSON.parse(response.body)['funding_rounds'].first
        expect(funding_round['id']).to               eq(@funding_round.id)
        expect(funding_round['company_id']).to       eq(@funding_round.company_id)
        expect(funding_round['round_code']).to       eq(@funding_round.round_code.titleize.gsub('Ipo', 'IPO'))
        expect(funding_round['raised_amount']).to    eq(@funding_round.raised_amount.to_s)
        expect(funding_round['funded_on']).to        eq(@funding_round.funded_on.strftime('%-m/%-d/%Y'))
        expect(funding_round['investor_ids']).to     eq([@investor.guid])
      end
    end
  end
end
