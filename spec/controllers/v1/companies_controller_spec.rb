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

      after(:each) do
        expected = { 'companies' => [] }
        expected['companies'].push(
          'id' => @company.id,
          'name' => @company.name,
          'category_id' => @company.category_id,
          'total_funding' => @company.total_funding.to_s,
          'funding_rounds' => [],
          'latitude' => @company.latitude.to_s,
          'longitude' => @company.longitude.to_s,
          'investor_ids' => [@investment.investor_guid]
        )

        expected['companies'][0]['funding_rounds'].push(
          'id' => @funding_round.id,
          'raised_amount' => @funding_round.raised_amount.to_s,
          'funded_on' => "#{@funding_round.funded_month}/#{@funding_round.funded_day}/#{@funding_round.funded_year}",
          'investor_ids' => [@investment.investor_guid]
        )

        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end
end
