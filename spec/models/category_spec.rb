require 'spec_helper'

describe Category do
  describe "associations" do
    before(:each) do
      @category = Category.new
    end
    subject { @category }
  
    it { should have_many :companies }
  end
  
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end
  
  describe "fields" do
    it { should respond_to :name }
  end

  describe "scopes" do
    describe "associated_with_companies" do
      it "needs tests"
    end
  end
end
