require 'spec_helper'

describe Category do
  before(:each) do
    @category = Category.new
  end

  describe 'associations' do
    it { expect(@category).to have_many :companies }
  end

  describe 'validations' do
    it { expect(@category).to validate_presence_of :name }
    it { expect(@category).to validate_uniqueness_of :name }
  end

  describe 'fields' do
    it { expect(@category).to respond_to :name }
    it { expect(@category).to respond_to :display_name }
  end

  describe 'scopes' do
    describe 'associated_with_companies' do
      before(:each) do
        @companies = [FactoryGirl.create(:company)]
        @included = FactoryGirl.create(:category, companies: @companies)
        @xcluded = FactoryGirl.create(:category)
      end

      it 'should return a category associated with the given company' do
        expect(Category.associated_with_companies(@companies)).to include(@included)
      end

      it 'should not return a category not associated with the given company' do
        expect(Category.associated_with_companies(@companies)).not_to include(@excluded)
      end
    end
  end
end
