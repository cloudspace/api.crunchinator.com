require 'spec_helper'

describe V1::InvestorsController do
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

      expected = {'investors' => []}
      expected['investors'].push({
        'id' => investor.id, 
        'name' => investor.name, 
        'zip_code' => "", 
        'investor_type' => investor.class.to_s.underscore
      })

      get :index
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end
end
