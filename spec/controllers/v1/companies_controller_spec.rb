require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do

    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate responses' do
      before(:each) do
        @company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: @company)
        @funding_round = FactoryGirl.create(:funding_round, company: @company)
        @investor =  FactoryGirl.create(:company, permalink: 'boo')
        @investment = FactoryGirl.create(:investment, investor: @investor, funding_round: @funding_round)
      end

      it 'with no arguments' do
        # don't do anything, this is already setup
        get :index
      end

      it 'when passing in a letter' do
        @company.name = 'Albert\s Apples'
        @company.save
        get :index, letter: 'a'
      end

      it 'when passing in a zero' do
        @company.name = '1st Albert\s Apples'
        @company.save
        get :index, letter: '0'
      end

      it 'with a company that is invalid due to lack of hq' do
        @unlocated_company = FactoryGirl.create(:company)
        get :index
      end

      it 'with a company with no funded funding rounds' do
        @unfunded_company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: @unfunded_company)
        @unfunded_funding_round = FactoryGirl.create(:funding_round,
                                                     company: @unfunded_company,
                                                     raw_raised_amount: BigDecimal.new('0'))
        get :index
      end

      after(:each) do
        expected = { 'companies' => [] }
        expected['companies'].push(
          'id' => @company.id,
          'permalink' => @company.permalink,
          'name' => @company.name,
          'category_id' => @company.category_id,
          'total_funding' => @company.total_funding,
          'funding_rounds' => [],
          'latitude' => @company.latitude.to_s,
          'longitude' => @company.longitude.to_s,
          'investor_ids' => [@investment.investor_guid]
        )

        expected['companies'][0]['funding_rounds'].push(
          'id' => @funding_round.id,
          'raised_amount' => @funding_round.raised_amount.to_s,
          'funded_on' => @funding_round.funded_on.strftime('%-m/%-d/%Y'),
          'investor_ids' => [@investment.investor_guid]
        )

        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end
end
