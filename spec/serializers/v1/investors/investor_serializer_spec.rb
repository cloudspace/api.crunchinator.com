require 'spec_helper'

describe V1::Investors::InvestorSerializer do
  before(:each) do
    @investor = Person.new({id: 1})
    @serializer = V1::Investors::InvestorSerializer.new(@investor)
  end

  it "output should match expected values" do
    output = JSON.parse(@serializer.to_json)

    expect(output).to have_key('investor')
    expect(output['investor']).to have_key('id')
    expect(output['investor']).to have_key('name')
    expect(output['investor']).to have_key('investor_type')
    expect(output['investor']).to have_key('zip_code')
  end

  describe 'investor_type' do
    it 'should return the investor type' do
      expect(@serializer.investor_type).to eq('person')
    end
  end

  describe 'zip_code' do
    it 'should call zip code if the investor has a zip code method' do
      @investor.stub(:zip_code).and_return("12345")
      expect(@serializer.zip_code).to eq("12345")
    end

    it 'should return a blank string if the investor has no zip code method' do
      expect(@serializer.zip_code).to eq("")
    end
  end
end
