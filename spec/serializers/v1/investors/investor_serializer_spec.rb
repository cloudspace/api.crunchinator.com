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

  describe "id" do
    it "should match an investment guid" do
      expect(@serializer.id).to eql("person-1")
    end

    it "should have the same output as investment.investor_guid" do
      investment = Investment.new(:investor => @investor)
      expect(@serializer.id).to eq(investment.investor_guid)
    end
  end

  describe 'investor_type' do
    it 'should return the investor type' do
      expect(@serializer.investor_type).to eq('person')
    end
  end

  describe 'invested_company_ids' do
    it "should return company ids" do
      funding_round = FundingRound.new(:company_id => 1)
      investment = Investment.new
      investment.stub(:funding_round).and_return(funding_round)
      @investor.stub(:investments).and_return([investment])
      expect(@serializer.invested_company_ids).to eql([1])
    end
  end

  describe 'invested_category_ids' do
    it "should return category ids" do
      investment = Investment.new
      investment.stub_chain(:funding_round, :company).and_return(Company.new(:category_id => 1))
      @investor.stub(:investments).and_return([investment])
      expect(@serializer.invested_category_ids).to eql([1])
    end
  end
end
