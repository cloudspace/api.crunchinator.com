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
    expect(output['company']).to have_key('zip_code')
    expect(output['company']).to have_key('total_funding')
    expect(output['company']).to have_key('category_id')
    expect(output['company']).to have_key('funding_rounds')
  end
end
