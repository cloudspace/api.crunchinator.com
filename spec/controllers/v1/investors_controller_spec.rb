require 'spec_helper'

describe V1::InvestorsController do
  describe 'index' do
    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate response' do
      before(:each) do
        company = FactoryGirl.create(:legit_company)
        @investor = FactoryGirl.create(:investor)
        fr = @investor.investments.first.funding_round
        fr.update_attribute :company, company
        company.funding_rounds = [fr]
      end

      it 'includes investors in legit companies' do
        # do nothing, general case
        get :index

        investor = JSON.parse(response.body)['investors'].first
        expect(investor['id']).to eq(@investor.guid)
        expect(investor['name']).to eq(@investor.name)
        expect(investor['investor_type']).to eq(@investor.class.to_s.underscore)
      end

      it 'includes company ids associated with the investor' do
        company = @investor.investments.first.funding_round.company

        get :index

        investor = JSON.parse(response.body)['investors'].first
        expect(investor['invested_company_ids']).to eq([company.id])
      end

      it 'includes category ids associated with the company invested in' do
        company = @investor.investments.first.funding_round.company

        get :index

        investor = JSON.parse(response.body)['investors'].first
        expect(investor['invested_category_ids']).to eq([company.category_id])
      end

      it 'excludes investors in illegit companies' do
        illegit_company = FactoryGirl.create(:company)
        excluded_investor = FactoryGirl.create(:investor)
        excluded_investor.investments.first.funding_round.update_attribute :company, illegit_company

        get :index

        investors = JSON.parse(response.body)['investors']
        expect(investors.length).to eq(1)
        expect(investors.map { |i| i['id'] }).not_to include(excluded_investor.guid)
      end

      describe 'when passing `letter` query param' do
        it 'filters out investors that begin with another letter' do
          @investor.update_attribute :name, 'Albert\'s Apples'
          excluded_investor = FactoryGirl.create(:investor, name: 'Bob\'s Bugers')
          excluded_investor.investments.first.funding_round.update_attribute :company, @company

          get :index, letter: 'A'

          investors = JSON.parse(response.body)['investors']
          expect(controller.params[:letter]).to eq('A')
          expect(investors.length).to eq(1)
          expect(investors.map { |i| i['id'] }).not_to include(excluded_investor.guid)
        end

        describe 'when passing `0` as the `letter`' do
          it 'filters out investors that begin with a alphabetic letter' do
            @investor.update_attribute :name, '1st Apples'
            excluded_investor = FactoryGirl.create(:investor, name: 'Albert\'s Apples')
            excluded_investor.investments.first.funding_round.update_attribute :company, @company

            get :index, letter: '0'

            investors = JSON.parse(response.body)['investors']
            expect(controller.params[:letter]).to eq('0')
            expect(investors.length).to eq(1)
            expect(investors.map { |i| i['id'] }).not_to include(excluded_investor.guid)
          end
        end
      end
    end
  end
end
