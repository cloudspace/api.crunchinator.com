require 'spec_helper'

describe FinancialOrganization do
  before(:each) do
    @financial_organization = FinancialOrganization.new
  end

  describe "associations" do
    it { expect(@financial_organization).to have_many :investments }
    it { expect(@financial_organization).to have_many :office_locations }
  end
  
  describe "validations" do
    it { expect(@financial_organization).to validate_presence_of :permalink }
    it { expect(@financial_organization).to validate_uniqueness_of :permalink }
  end
  
  describe "fields" do
    it { expect(@financial_organization).to respond_to :name }
    it { expect(@financial_organization).to respond_to :permalink }
    it { expect(@financial_organization).to respond_to :crunchbase_url}
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

  describe "scopes" do
    describe "non_alpha" do 
      it "should return financial_organizations whose name starts with a number" do
        included = FactoryGirl.create(:financial_organization, :name => "#Hashtag")
        expect(FinancialOrganization.non_alpha).to include(included)
      end

      it "should return financial_organizations whose name starts with a symbol" do
        included = FactoryGirl.create(:financial_organization, :name => "1st")
        expect(FinancialOrganization.non_alpha).to include(included)
      end

      it "should not return financial_organizations whose name starts with a letter" do
        excluded = FactoryGirl.create(:financial_organization, :name => "Albert's Apples")
        expect(FinancialOrganization.non_alpha).not_to include(excluded)
      end
    end

    describe "starts_with" do
      before(:each) do
        @included = FactoryGirl.create(:financial_organization, :name => "Albert's Apples")
      end

      it "should return financial_organizations whose name starts with the specified character" do
        expect(FinancialOrganization.starts_with("A")).to include(@included)
      end

      it "should not exclude financial_organizations due to capitalization" do
        expect(FinancialOrganization.starts_with("a")).to include(@included)
      end

      it "should not return financial_organizations whose name does not start with the specified character" do
        excluded = FactoryGirl.create(:financial_organization, :name => "Pete's Pears")
        expect(FinancialOrganization.starts_with("a")).not_to include(excluded)
      end
    end
  end

  describe "instance methods" do
    before(:each) do
      @financial_organization = FinancialOrganization.new
    end

    describe "headquarters" do
      it "should return the first office location that is a headquarter" do
        @financial_organization = FactoryGirl.create(:financial_organization)
        
        office = FactoryGirl.create(:office_location, :headquarters => false, :tenant => @financial_organization)
        headquarter = FactoryGirl.create(:office_location, :headquarters => true, :tenant => @financial_organization)
        expect(@financial_organization.headquarters).to eql(headquarter)
      end

      it "should return nil if there are no headquarters" do
        expect(@financial_organization.headquarters).to be_nil
      end
    end
  end
end
