require 'spec_helper'

describe V1::Categories::CategorySerializer do
  before(:each) do
    @category = FactoryGirl.build(:category)
    @serializer = V1::Categories::CategorySerializer.new(@category)
  end

  it 'output should match expected values' do
    output = JSON.parse(@serializer.to_json)

    expect(output).to have_key('category')
    expect(output['category']).to have_key('id')
    expect(output['category']).to have_key('name')
    expect(output['category']).to have_key('company_ids')
    expect(output['category']).to have_key('investor_ids')
  end

  describe 'company_ids' do
    it 'should return the ids of valid companies' do
      # this just tests the implementation but I am not sure of a better way to do it
      @category.stub_chain(:companies, :valid, :pluck).and_return([1])
      expect(@serializer.company_ids).to eql([1])
    end
  end

  describe 'investor_ids' do
    it 'should return type-id unique ids for investors' do
      investment = Investment.new(investor_type: 'Company', investor_id: '1')
      Investment.stub_chain(:joins, :merge).and_return([investment])
      expect(@serializer.investor_ids).to eql(['company-1'])
    end
  end
end
