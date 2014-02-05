require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do

    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate responses' do
      before(:each) do
        @company = FactoryGirl.create(:valid_company)
      end

      it 'includes valid companies' do
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
          expect(company['funding_rounds'].first).to eq('id' => @funding_round.id,
                                                        'raised_amount' => @funding_round.raised_amount.to_s,
                                                        'funded_on' => @funding_round.funded_on.strftime('%-m/%-d/%Y'),
                                                        'investor_ids' => [@investor.guid]
                                                       )
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

      describe 'when passing `letter` query param' do
        it 'filters out companies that begin with another letter' do
          @company.update_attribute :name, 'Albert\'s Albert'
          excluded_company = FactoryGirl.create(:valid_company, name: 'Bob\'s Burgers')

          get :index, letter: 'A'

          companies = JSON.parse(response.body)['companies']
          expect(controller.params[:letter]).to eq('A')
          expect(companies.length).to eq(1)
          expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
        end

        describe 'when passing `0` as the `letter`' do
          it 'filters out investors that begin with a alphabetic letter' do
            @company.update_attribute :name, '1st Albert'
            excluded_company = FactoryGirl.create(:valid_company, name: 'Albert\'s Apples')

            get :index, letter: '0'

            companies = JSON.parse(response.body)['companies']
            expect(controller.params[:letter]).to eq('0')
            expect(companies.length).to eq(1)
            expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
          end
        end
      end

      describe 'excludes' do
        it 'companies that do not have an hq' do
          excluded_company = FactoryGirl.create(:valid_company, office_locations: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
        end

        it 'companies with no funded funding rounds' do
          excluded_company = FactoryGirl.create(:valid_company, funding_rounds: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map { |i| i['id'] }).not_to include(excluded_company.id)
        end
      end
    end
  end
end
