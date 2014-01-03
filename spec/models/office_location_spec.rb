require 'spec_helper'

describe OfficeLocation do
  describe "associations" do
    before(:each) do
      @office_location = OfficeLocation.new
    end
    subject { @office_location }
  
    it { should belong_to :tenant }
  end
  
  describe "validations" do
    it { should validate_presence_of :tenant }
  end
  
  describe "fields" do
    it { should respond_to :tenant_id }
    it { should respond_to :tenant_type }
    it { should respond_to :headquarters }
    it { should respond_to :description }
    it { should respond_to :address1 }
    it { should respond_to :address2 }
    it { should respond_to :zip_code }
    it { should respond_to :city }
    it { should respond_to :state_code }
    it { should respond_to :country_code }
    it { should respond_to :latitude }
    it { should respond_to :longitude }
  end

  describe "instance methods" do
    describe "geolocate" do
      it "should be called after create"
      it "needs tests"
    end
  end
end
