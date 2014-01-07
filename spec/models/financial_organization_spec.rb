require 'spec_helper'

describe FinancialOrganization do
  describe "associations" do
    before(:each) do
      @financial_organization = FinancialOrganization.new
    end
    subject { @financial_organization }
  
    it { should have_many :investments }
    it { should have_many :office_locations }
  end
  
  describe "validations" do
    it { should validate_presence_of :permalink }
    it { should validate_uniqueness_of :permalink }
  end
  
  describe "fields" do
    it { should respond_to :name }
    it { should respond_to :permalink }
    it { should respond_to :crunchbase_url}
    it { should respond_to :blog_url }
    it { should respond_to :blog_feed_url }
    it { should respond_to :twitter_username }
    it { should respond_to :phone_number }
    it { should respond_to :email_address }
    it { should respond_to :description }
    it { should respond_to :number_of_employees }
    it { should respond_to :founded_date }
    it { should respond_to :overview }  
  end

  describe "scopes" do
    describe "non_alpha" do 
      it "should return financial_organizations whose name starts with a number" do
        included = FactoryGirl.create(:financial_organization, :name => "#Hashtag")
        FinancialOrganization.non_alpha.should include(included)
      end

      it "should return financial_organizations whose name starts with a symbol" do
        included = FactoryGirl.create(:financial_organization, :name => "1st")
        FinancialOrganization.non_alpha.should include(included)
      end

      it "should not return financial_organizations whose name starts with a letter" do
        excluded = FactoryGirl.create(:financial_organization, :name => "Albert's Apples")
        FinancialOrganization.non_alpha.should_not include(excluded)
      end
    end

    describe "starts_with" do
      before(:each) do
        @included = FactoryGirl.create(:financial_organization, :name => "Albert's Apples")
      end

      it "should return financial_organizations whose name starts with the specified character" do
        FinancialOrganization.starts_with("A").should include(@included)
      end

      it "should not exclude financial_organizations due to capitalization" do
        FinancialOrganization.starts_with("a").should include(@included)
      end

      it "should not return financial_organizations whose name does not start with the specified character" do
        excluded = FactoryGirl.create(:financial_organization, :name => "Pete's Pears")
        FinancialOrganization.starts_with("a").should_not include(excluded)
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
