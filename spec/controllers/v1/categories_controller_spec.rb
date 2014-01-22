require 'spec_helper'

describe V1::CategoriesController do
  describe 'index' do
    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate response' do
      before(:each) do
        @company = FactoryGirl.create(:company)
        @category = @company.category
        FactoryGirl.create(:headquarters, tenant: @company)
        @funding_round = FactoryGirl.create(:funding_round, company: @company)
        @investor =  FactoryGirl.create(:company, permalink: 'boo')
        @investment = FactoryGirl.create(:investment, investor: @investor, funding_round: @funding_round)
      end

      it 'with a valid company' do
        get :index
      end

      it 'with a category with no valid companies' do
        @invalid_company = FactoryGirl.create(:company)
        @invalid_category = @invalid_company.category
        get :index
      end

      after(:each) do
        expected = { 'categories' => [] }
        expected['categories'].push(
          'id' => @category.id,
          'name' => @category.name,
          'company_ids' => [@company.id],
          'investor_ids' => [@investment.investor_guid]
        )
        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end
end
