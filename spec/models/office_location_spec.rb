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
      it "should be called after create" do
        location = FactoryGirl.build(:office_location)
        location.should_receive(:geolocate)
        location.save
      end

      it "should return nil if the zip code is blank" do
        location = OfficeLocation.new(:zip_code => nil)
        expect(location.geolocate).to be_nil
      end

      it "should return nil if the country code is not USA" do
        location = OfficeLocation.new(:zip_code => "12345", :country_code => "Canada")
        expect(location.geolocate).to be_nil
      end

      it "should return true without saving if the zip code includes nondigits" do
        location = FactoryGirl.build(:office_location, :zip_code => "123abc")
        expect(location.geolocate).to be_true
      end

      it "should set the longitude and latitude when saving" do
        location = FactoryGirl.build(:office_location)
        ZipCodeGeo.stub(:find_by_zip_code).and_return(FactoryGirl.build(:zip_code_geo))

        location.geolocate

        expect(location.latitude).to be_present
        expect(location.longitude).to be_present
      end
    end
  end
end
