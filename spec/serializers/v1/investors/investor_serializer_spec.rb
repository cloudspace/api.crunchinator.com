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
    expect(output['investor']).to have_key('invested_company_ids')
    expect(output['investor']).to have_key('invested_category_ids')
  end

  describe 'investor_type' do
    it 'should return the investor type' do
      expect(@serializer.investor_type).to eq('person')
    end
  end

  describe 'invested_company_ids' do
    it "needs tests"
  end

  describe 'invested_category_ids' do
    it "needs tests"
  end
end
