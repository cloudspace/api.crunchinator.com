require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do
    it "should return a 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it 'should return an appropriate response' do
      pending "This test no longer matches the json outputted by the controllers"
      company = FactoryGirl.create(:company)
      funding_round = FactoryGirl.create(:funding_round, company: company)
      investor =  FactoryGirl.create(:company, permalink: "boo")
      investment = FactoryGirl.create(:investment, investor: investor, funding_round: funding_round)

      expected = {'companies' => []}
      expected['companies'].push({
        'id' => company.id, 
        'name' => company.name, 
        'category_id' => company.category_id,
        'total_funding' => company.total_funding.to_s,
        'latitude' => company.latitude,
        'longitude' => company.longitude,
        'investor_ids' => ['person-' + investor.id.to_s],
        'funding_rounds' => []
      })

      expected['companies'][0]['funding_rounds'].push({
        'id' => funding_round.id,
        'raised_amount' => funding_round.raised_amount.to_s,
        'funded_on' => funding_round.funded_on.to_s,
        'investors' => [{'id' => investor.id, 'name' => investor.name}]
      })

      get :index
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end
end
