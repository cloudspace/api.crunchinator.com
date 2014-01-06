require 'spec_helper'

describe V1::Companies::NestedFundingRoundSerializer do
  before(:each) do
    @funding_round = FundingRound.new({:id => 1})
    @serializer = V1::Companies::NestedFundingRoundSerializer.new(@funding_round)
  end

  it "output should match expected values" do
    output = JSON.parse(@serializer.to_json)

    expect(output).to have_key('nested_funding_round')
    expect(output['nested_funding_round']).to have_key('id')
    expect(output['nested_funding_round']).to have_key('raised_amount')
    expect(output['nested_funding_round']).to have_key('funded_on')
  end

  describe "investor_ids" do
    it "should return a list of investment guids" do
      investment = Investment.new(:investor_type => "Company", :investor_id => "1")
      @funding_round.stub(:investments).and_return([investment])

      expect(@serializer.investor_ids).to eql(["company-1"])
    end
  end
end
