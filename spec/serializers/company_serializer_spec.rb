require 'spec_helper'

describe CompanySerializer do
  before(:each) do
    @company = Company.new({:id => "1", :name => "Jeremiah's company"})
    @serializer = CompanySerializer.new(@company)
  end

  it "output should match expected values" do
    # this is not a great test.  I would recommend converting the json back to a hash and testing the hash keys (JH 12-3-2013)
    expect(@serializer.to_json).to eq("{\"company\":{\"id\":1,\"name\":\"Jeremiah's company\",\"permalink\":null,\"custom_field\":\"If this isn't changed, then the current message will be included in the JSON response.\",\"funding_rounds\":[]}}")
  end
end
