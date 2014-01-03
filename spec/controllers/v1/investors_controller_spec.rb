require 'spec_helper'

describe V1::InvestorsController do
  describe 'index' do
    it "should return a 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it 'should return an appropriate response' do
      company = Company.make!
      funding_round = FundingRound.make!(company: company)
      investor = Person.make!(permalink: "boo")
      investment = Investment.make!(investor: investor, funding_round: funding_round)

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
