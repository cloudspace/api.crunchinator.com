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
        @acquisition = FactoryGirl.create(:acquisition, acquired_company: @company)
        @ipo = FactoryGirl.create(:initial_public_offering, company: @company)
        @funding_round = @company.funding_rounds.first
        @investor = @funding_round.investments.first.investor
      end

      it 'includes valid companies' do
        get :index

        company = JSON.parse(response.body)['companies'].first
        expect(company['id']).to               eq(@company.id)
        expect(company['permalink']).to        eq(@company.permalink)
        expect(company['name']).to             eq(@company.name)
        expect(company['category_id']).to      eq(@company.category_id)
        expect(company['total_funding']).to    eq(@company.total_funding)
        expect(company['latitude']).to         eq(@company.latitude.to_s)
        expect(company['longitude']).to        eq(@company.longitude.to_s)
        expect(company['founded_on']).to       eq(@company.founded_on.strftime('%-m/%-d/%Y'))

        expect(company['investor_ids']).to     eq([@investor.guid])

        expect(company['status']).to           eq('acquired')
        expect(company['acquired_on']).to      eq(@acquisition.acquired_on.strftime('%-m/%-d/%Y'))
        expect(company['acquired_by_id']).to   eq(@acquisition.acquiring_company_id)

        expect(company['ipo_valuation']).to eq(@company.initial_public_offering.usd_valuation)
        expect(company['ipo_on']).to eq(@company.initial_public_offering.offering_on.strftime('%-m/%-d/%Y'))
        expect(company['state_code']).to eq(@company.headquarters.state_code)

        expect(company['funding_rounds']).to eq([{
          'id' => @funding_round.id,
          'raised_amount' => @funding_round.raised_amount.to_s,
          'funded_on' => @funding_round.funded_on.strftime('%-m/%-d/%Y'),
          'investor_ids' => [@investor.guid]
        }])
      end

      describe 'when passing `letter` query param' do
        it 'filters out companies that begin with another letter' do
          @company.update_attribute :name, 'Albert\'s Albert'
          excluded_company = FactoryGirl.create(:valid_company, name: 'Bob\'s Burgers')

          get :index, :letter => 'A'

          companies = JSON.parse(response.body)['companies']
          expect(controller.params[:letter]).to eq('A')
          expect(companies.length).to eq(1)
          expect(companies.map{ |i| i['id'] }).not_to include(excluded_company.id)
        end

        describe 'when passing `0` as the `letter`' do
          it 'filters out investors that begin with a alphabetic letter' do
            @company.update_attribute :name, '1st Albert'
            excluded_company = FactoryGirl.create(:valid_company, name: 'Albert\'s Apples')

            get :index, :letter => '0'

            companies = JSON.parse(response.body)['companies']
            expect(controller.params[:letter]).to eq('0')
            expect(companies.length).to eq(1)
            expect(companies.map{ |i| i['id'] }).not_to include(excluded_company.id)
          end
        end
      end

      describe 'excludes' do
        it 'companies that do not have an hq' do
          excluded_company = FactoryGirl.create(:valid_company, office_locations: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map{ |i| i['id'] }).not_to include(excluded_company.id)
        end

        it 'companies with no funded funding rounds' do
          excluded_company = FactoryGirl.create(:valid_company, funding_rounds: [])

          get :index

          companies = JSON.parse(response.body)['companies']
          expect(companies.length).to eq(1)
          expect(companies.map{ |i| i['id'] }).not_to include(excluded_company.id)
        end
      end
    end
  end
end
