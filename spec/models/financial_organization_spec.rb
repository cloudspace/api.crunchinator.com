require 'spec_helper'

describe FinancialOrganization do
  before(:each) do
    @financial_organization = FinancialOrganization.new
  end

  describe 'mixins' do
    it 'should be an investor' do
      expect(FinancialOrganization.ancestors.select { |o| o.class == Module }).to include(Investor)
    end
  end

  describe 'associations' do
    it { expect(@financial_organization).to have_many :investments }
    it { expect(@financial_organization).to have_many :office_locations }
  end

  describe 'validations' do
    it { expect(@financial_organization).to validate_presence_of :permalink }
    it { expect(@financial_organization).to validate_uniqueness_of :permalink }
  end

  describe 'fields' do
    it { expect(@financial_organization).to respond_to :name }
    it { expect(@financial_organization).to respond_to :permalink }
    it { expect(@financial_organization).to respond_to :crunchbase_url }
    it { expect(@financial_organization).to respond_to :blog_url }
    it { expect(@financial_organization).to respond_to :blog_feed_url }
    it { expect(@financial_organization).to respond_to :twitter_username }
    it { expect(@financial_organization).to respond_to :phone_number }
    it { expect(@financial_organization).to respond_to :email_address }
    it { expect(@financial_organization).to respond_to :description }
    it { expect(@financial_organization).to respond_to :number_of_employees }
    it { expect(@financial_organization).to respond_to :founded_date }
    it { expect(@financial_organization).to respond_to :overview }
  end

  describe 'scopes' do
  end

  describe 'instance methods' do
    before(:each) do
      @financial_organization = FinancialOrganization.new
    end

    describe 'headquarters' do
      it 'should return the first office location that is a headquarter' do
        @financial_organization = FactoryGirl.create(:financial_organization)

        office = FactoryGirl.create(:office_location, headquarters: false, tenant: @financial_organization)
        expect(@financial_organization.headquarters).not_to eql(office)

        headquarter = FactoryGirl.create(:office_location, headquarters: true, tenant: @financial_organization)
        expect(@financial_organization.headquarters).to eql(headquarter)
      end

      it 'should return nil if there are no headquarters' do
        expect(@financial_organization.headquarters).to be_nil
      end
    end
  end
end
