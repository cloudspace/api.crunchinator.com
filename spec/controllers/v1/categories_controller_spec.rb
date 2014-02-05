require 'spec_helper'

describe V1::CategoriesController do
  describe 'index' do
    it 'should return a 200' do
      get :index
      expect(response.status).to eq(200)
    end

    describe 'appropriate response' do
      before(:each) do
        @category = FactoryGirl.create(:valid_category)
      end

      it 'includes categories that have a valid company' do
        get :index

        category = JSON.parse(response.body)['categories'].first
        expect(category['id']).to eq(@category.id)
        expect(category['name']).to eq(@category.name)
      end

      it 'includes company ids associated with the category' do
        company_ids = @category.companies.pluck(:id)

        get :index

        category = JSON.parse(response.body)['categories'].first
        expect(category['company_ids']).to eq(company_ids)
      end

      it 'includes investor ids associated with the category' do
        company = @category.companies.first
        @investor = FactoryGirl.create(:investor)
        @investor.investments.first.funding_round.update_attribute :company, company

        get :index

        category = JSON.parse(response.body)['categories'].first
        expect(category['investor_ids']).to eq([@investor.guid])
      end

      it 'excludes categories that have no valid companies' do
        excluded_category = FactoryGirl.create(:category, companies: [])
        get :index

        categories = JSON.parse(response.body)['categories']
        expect(categories.length).to eq(1)
        expect(categories.map{ |c| c['id'] }).not_to include(excluded_category.id)
      end
    end
  end
end
