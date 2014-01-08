require 'spec_helper'

describe OfficeLocation do
  before(:each) do
    @office_location = OfficeLocation.new
  end

  describe 'associations' do
    it { expect(@office_location).to belong_to :tenant }
  end

  describe 'validations' do
    it { expect(@office_location).to validate_presence_of :tenant }
  end

  describe 'fields' do
    it { expect(@office_location).to respond_to :tenant_id }
    it { expect(@office_location).to respond_to :tenant_type }
    it { expect(@office_location).to respond_to :headquarters }
    it { expect(@office_location).to respond_to :description }
    it { expect(@office_location).to respond_to :address1 }
    it { expect(@office_location).to respond_to :address2 }
    it { expect(@office_location).to respond_to :zip_code }
    it { expect(@office_location).to respond_to :city }
    it { expect(@office_location).to respond_to :state_code }
    it { expect(@office_location).to respond_to :country_code }
    it { expect(@office_location).to respond_to :latitude }
    it { expect(@office_location).to respond_to :longitude }
  end

  describe 'scopes' do
    describe 'headquarters' do
      it 'should include headquarters' do
        headquarters = FactoryGirl.create(:headquarters)
        expect(OfficeLocation.headquarters).to include(headquarters)
      end

      it 'should not include other offices' do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.headquarters).not_to include(office)
      end
    end

    describe 'geolocated_headquarters' do
      it 'should include headquarters with both longitude and latitude data' do
        headquarters = FactoryGirl.create(:headquarters)
        expect(OfficeLocation.geolocated_headquarters).to include(headquarters)
      end

      it 'should not include offices that aren\'t headquarters' do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.geolocated_headquarters).not_to include(office)
      end

      it 'should not include offices with missing latitude data' do
        headquarters = FactoryGirl.create(:headquarters)
        headquarters.latitude = nil
        headquarters.save
        expect(OfficeLocation.geolocated_headquarters).not_to include(headquarters)
      end

      it 'should not include offices with missing longitude data' do
        headquarters = FactoryGirl.create(:headquarters)
        headquarters.longitude = nil
        headquarters.save
        expect(OfficeLocation.geolocated_headquarters).not_to include(headquarters)
      end
    end

    describe 'in_america' do
      it 'should include locations in america' do
        office = FactoryGirl.create(:office_location)
        expect(OfficeLocation.in_usa).to include(office)
      end

      it 'should not include locations outside of america based on the country code' do
        office = FactoryGirl.create(:office_location, country_code: 'Canada')
        expect(OfficeLocation.in_usa).not_to include(office)
      end

      it 'should not include locations outside of america based on the longitude' do
        office = FactoryGirl.create(:office_location, longitude: '0')
        expect(OfficeLocation.in_usa).not_to include(office)
      end

      it 'should not include recordswith a missing longitude or latitude' do
        office = FactoryGirl.create(:office_location, longitude: nil, latitude: nil)
        expect(OfficeLocation.in_usa).not_to include(office)
      end
    end
  end

  describe 'instance methods' do
    describe 'geolocate' do
      it 'should be called after create' do
        location = FactoryGirl.build(:office_location)
        location.should_receive(:geolocate)
        location.save
      end

      it 'should return nil if the zip code is blank' do
        location = OfficeLocation.new(zip_code: nil)
        expect(location.geolocate).to be_nil
      end

      it 'should return nil if the country code is not USA' do
        location = OfficeLocation.new(zip_code: '12345', country_code: 'Canada')
        expect(location.geolocate).to be_nil
      end

      it 'should return true without saving if the zip code includes nondigits' do
        location = FactoryGirl.build(:office_location, zip_code: '123abc')
        expect(location.geolocate).to be_true
      end

      it 'should set the longitude and latitude when saving' do
        location = FactoryGirl.build(:office_location)
        ZipCodeGeo.stub(:find_by_zip_code).and_return(FactoryGirl.build(:zip_code_geo))

        location.geolocate

        expect(location.latitude).to be_present
        expect(location.longitude).to be_present
      end
    end
  end
end
