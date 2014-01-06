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

  describe "scopes" do
    describe "headquarters" do
      it "should include headquarters" do
        headquarters = FactoryGirl.create(:headquarters)
        expect(OfficeLocation.headquarters).to include(headquarters)
      end

      it "should not include other offices" do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.headquarters).not_to include(office)
      end
    end

    describe "geolocated_headquarters" do
      it "should include headquarters with both longitude and latitude data" do
        headquarters = FactoryGirl.create(:headquarters)
        expect(OfficeLocation.geolocated_headquarters).to include(headquarters)
      end

      it "should not include offices that aren't headquarters" do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.geolocated_headquarters).not_to include(office)
      end

      it "should not include offices with missing latitude data" do
        headquarters = FactoryGirl.create(:headquarters)
        headquarters.latitude = nil
        headquarters.save
        expect(OfficeLocation.geolocated_headquarters).not_to include(headquarters)
      end

      it "should not include offices with missing longitude data" do
        headquarters = FactoryGirl.create(:headquarters)
        headquarters.longitude = nil
        headquarters.save
        expect(OfficeLocation.geolocated_headquarters).not_to include(headquarters)
      end
    end

    describe "in_america" do
      it "should include locations in america" do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.in_usa).to include(office)
      end

      it "should not include locations outside of america based on the country code" do
        office = FactoryGirl.create(:office_location, :country_code => "Canada")
        expect(OfficeLocation.in_usa).not_to include(office) 
      end

      it "should not include locations outside of america based on the longitude" do
        office = FactoryGirl.create(:office_location, :longitude => "0")
        expect(OfficeLocation.in_usa).not_to include(office)  
      end

      it "should not include recordswith a missing longitude or latitude" do
        office = FactoryGirl.create(:office_location, :longitude => nil, :latitude => nil)
        expect(OfficeLocation.in_usa).not_to include(office)  
      end
    end
  end

  describe "instance methods" do
    describe "geolocate" do
      it "should be called after create"
      it "needs tests"
    end
  end
end
