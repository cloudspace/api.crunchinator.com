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
      @financial_oranization = FinancialOrganization.new
    end

    describe "headquarters" do
      it "needs tests"
    end
  end
end
