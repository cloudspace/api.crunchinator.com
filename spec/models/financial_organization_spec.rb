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
      it "needs tests"
    end
  end

  describe "class methods" do
    describe "starts_with" do
      it "needs tests"
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
