require 'spec_helper'

describe V1::InvestorsController do
  describe 'index' do
    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'should return an appropriate response' do
      # pending 'This test no longer matches the json outputted by the controllers'
      company = FactoryGirl.create(:company)
      FactoryGirl.create(:headquarters, tenant: company)
      funding_round = FactoryGirl.create(:funding_round, company: company)
      investor =  FactoryGirl.create(:company, permalink: 'boo')
      investment = FactoryGirl.create(:investment, investor: investor, funding_round: funding_round)

      expected = { 'investors' => [] }
      expected['investors'].push(
        'id' => investment.investor_type.underscore + '-' + investor.id.to_s,
        'name' => investor.name,
        'investor_type' => investor.class.to_s.underscore,
        'invested_company_ids' => [company.id],
        'invested_category_ids' => [company.category_id]
      )

      get :index
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end
end
