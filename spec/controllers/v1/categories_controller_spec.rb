require 'spec_helper'

describe V1::CategoriesController do
  describe "index" do
    it "should return a 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it 'should return an appropriate response' do
      # pending "This test no longer matches the json outputted by the controllers"
      company = FactoryGirl.create(:company)
      category = company.category
      headquarters = FactoryGirl.create(:headquarters, tenant: company)
      funding_round = FactoryGirl.create(:funding_round, company: company)
      investor =  FactoryGirl.create(:company, permalink: "boo")
      investment = FactoryGirl.create(:investment, investor: investor, funding_round: funding_round)

      expected = {'categories' => []}
      expected['categories'].push({
        'id' => category.id,
        'name' => category.name,
        'company_ids' => [company.id],
        'investor_ids' => [investment.investor_type.underscore + "-" + investor.id.to_s]
      })

      get :index
      expect(JSON.parse(response.body)).to eq(expected)
    end
  end
end
