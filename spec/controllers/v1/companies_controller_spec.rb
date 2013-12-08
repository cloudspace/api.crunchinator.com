require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do
    it "should return a 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it 'should return an appropriate response' do
      company = Company.make!
      funding_round = FundingRound.make!(:company => company)
      investor = Person.make!
      investment = Investment.make!(:investor => investor, :funding_round => funding_round)

      expected = {'companies' => []}
      expected['companies'].push({
        'id' => company.id, 
        'name' => company.name, 
        'zip_code' => company.zip_code, 
        'total_funding' => company.total_funding.to_s,
        'category_id' => company.category_id,
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
