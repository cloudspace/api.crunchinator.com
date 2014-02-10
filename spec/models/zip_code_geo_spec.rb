require 'spec_helper'

describe ZipCodeGeo do
  before(:each) do
    @geo = ZipCodeGeo.new
  end

  describe 'fields' do
    it { expect(@geo).to respond_to(:zip_code) }
    it { expect(@geo).to respond_to :city }
    it { expect(@geo).to respond_to :state }
    it { expect(@geo).to respond_to :longitude }
    it { expect(@geo).to respond_to :latitude }
  end

  describe 'class methods' do
    describe 'import_from_csv' do
      it 'should add some zip codes' do
        ZipCodeGeo.import_from_csv(File.new(Rails.root.to_s + '/spec/fixtures/zip_codes.csv', 'r'))
        expect(ZipCodeGeo.count).to eq(1)
      end

      it 'should not add zip codes which have already been added' do
        ZipCodeGeo.import_from_csv(File.new(Rails.root.to_s + '/spec/fixtures/zip_codes.csv', 'r'))
        ZipCodeGeo.import_from_csv(File.new(Rails.root.to_s + '/spec/fixtures/zip_codes.csv', 'r'))
        expect(ZipCodeGeo.count).to eq(1)
      end
    end
  end
end
