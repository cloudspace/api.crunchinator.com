require 'spec_helper'

describe V1::InvestorsController do
  describe 'index' do
    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate response' do
      before(:each) do
        @company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: @company)
        @funding_round = FactoryGirl.create(:funding_round, company: @company)
        @investor =  FactoryGirl.create(:company, permalink: 'boo')
        @investment = FactoryGirl.create(:investment, investor: @investor, funding_round: @funding_round)
      end

      it 'with no query params' do
        # do nothing, general case
        get :index
      end

      it 'with a letter as a query param' do
        @investor.name = 'Albert\'s Apples'
        @investor.save
        get :index
      end

      it 'with a number as a query param' do
        @investor.name = '1st Apples'
        @investor.save
        get :index
      end

      it 'should not include investors for companies with no valid funding rounds' do
        @unfunded_company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: @unfunded_company)
        @unfunded_funding_round = FactoryGirl.create(:unfunded_funding_round, company: @unfunded_company)
        @unfunded_investor =  FactoryGirl.create(:company, permalink: 'fred')
        @unfunded_investment = FactoryGirl.create(:investment,
                                                  investor: @unfunded_investor,
                                                  funding_round: @unfunded_funding_round)
        get :index
      end

      after(:each) do
        expected = { 'investors' => [] }
        expected['investors'].push(
          'id' => @investor.guid,
          'name' => @investor.name,
          'investor_type' => @investor.class.to_s.underscore,
          'invested_company_ids' => [@company.id],
          'invested_category_ids' => [@company.category_id]
        )

        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end
end
