require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do

    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate responses' do
      before(:each) do
        @company = FactoryGirl.create(:legit_company)
      end

      it 'includes legit companies' do
        get :index

        company = JSON.parse(response.body)['companies'].first
        expect(company['id']).to               eq(@company.id)
        expect(company['permalink']).to        eq(@company.permalink)
        expect(company['name']).to             eq(@company.name)
        expect(company['category_id']).to      eq(@company.category_id)
        expect(company['founded_on']).to       eq(@company.founded_on.strftime('%-m/%-d/%Y'))
      end

      describe 'includes investments' do
        before(:each) do
          @funding_round = @company.funding_rounds.first
          investment = FactoryGirl.create(:investment, funding_round: @funding_round)
          @investor = investment.investor
        end

        it 'includes investor ids associated with the company' do
          get :index

          company = JSON.parse(response.body)['companies'].first
          expect(company['investor_ids']).to eq([@investor.guid])
        end

        it 'includes funding_rounds associated with the company' do
          get :index

          company = JSON.parse(response.body)['companies'].first
          expect(company['total_funding']).to eq(@company.total_funding)
          expect(company['funding_rounds'].length).to eq(1)

          funding_round = company['funding_rounds'].first
          expect(funding_round['id']).to eq(@funding_round.id)
          expect(funding_round['id']).to eq(@funding_round.id)
          expect(funding_round['raised_amount']).to eq(@funding_round.raised_amount.to_s)
          expect(funding_round['funded_on']).to eq(@funding_round.funded_on.strftime('%-m/%-d/%Y'))
          expect(funding_round['investor_ids']).to eq([@investor.guid])
        end
      end

      describe 'includes geolocation' do
        it 'includes latitude' do
          get :index

          company = JSON.parse(response.body)['companies'].first
          expect(company['latitude']).to eq(@company.latitude.to_s)
        end

        it 'includes longitude' do
          get :index

          company = JSON.parse(response.body)['companies'].first
          expect(company['longitude']).to eq(@company.longitude.to_s)
        end
      end

      it 'includes acquisition status' do
        acquisition = FactoryGirl.create(:acquisition, acquired_company: @company)

        get :index

        company = JSON.parse(response.body)['companies'].first
        expect(company['status']).to           eq('acquired')
        expect(company['acquired_on']).to      eq(acquisition.acquired_on.strftime('%-m/%-d/%Y'))
        expect(company['acquired_by_id']).to   eq(acquisition.acquiring_company_id)
      end

      it 'includes associated IPO' do
        ipo = FactoryGirl.create(:initial_public_offering, company: @company)
        get :index

        company = JSON.parse(response.body)['companies'].first
        expect(company['ipo_valuation']).to eq(ipo.usd_valuation)
        expect(company['ipo_on']).to eq(ipo.offering_on.strftime('%-m/%-d/%Y'))
      end

      it 'includes state_code' do
        get :index

        company = JSON.parse(response.body)['companies'].first
        expect(company['state_code']).to eq(@company.headquarters.state_code)
      end

      describe 'excludes' do
        it 'companies that do not have an hq' do
          excluded_company = FactoryGirl.create(:legit_company, office_locations: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
        end

        it 'companies with no funded funding rounds' do
          excluded_company = FactoryGirl.create(:legit_company, funding_rounds: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
        end
      end
    end
  end
end
