require 'spec_helper'

describe V1::Companies::CompanySerializer do
  before(:each) do
    @company = Company.new({:id => "1", :name => "Jeremiah's company"})
    @serializer = V1::Companies::CompanySerializer.new(@company)
  end

  it "output should match expected values" do
    output = JSON.parse(@serializer.to_json)

    expect(output).to have_key('company')
    expect(output['company']).to have_key('id')
    expect(output['company']).to have_key('name')
    expect(output['company']).to have_key('category_id')
    expect(output['company']).to have_key('total_funding')
    expect(output['company']).to have_key('longitude')
    expect(output['company']).to have_key('latitude')
    expect(output['company']).to have_key('investor_ids')
    expect(output['company']).to have_key('funding_rounds')
  end

  describe "investor_ids" do
    it "should return a list of investor guids" do
      investment = Investment.new(:investor_type => "Company", :investor_id => "1")
      funding_round = FundingRound.new
      funding_round.stub(:investments).and_return([investment])
      @company.stub(:funding_rounds).and_return([funding_round])

      expect(@serializer.investor_ids).to eq(["company-1"])
    end
  end
end
