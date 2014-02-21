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
    describe 'legit' do
      let(:included) { FactoryGirl.create(:legit_category) }
      let(:excluded) { FactoryGirl.create(:category) }

      it 'includes categories that are associated with legit companies' do
        expect(Category.legit).to include(included)
      end

      it 'excludes categories that are not associated with legit companies' do
        expect(Category.legit).not_to include(excluded)
      end
    end
  end
end
