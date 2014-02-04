require 'spec_helper'

describe V1::Companies::CompanySerializer do
  before(:each) do
    @company = Company.new(id: '1', name: 'Jeremiah\'s company')
    @serializer = V1::Companies::CompanySerializer.new(@company)
  end

  it 'output should match expected values' do
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
    expect(output['company']).to have_key('founded_on')
    expect(output['company']).to have_key('status')
    expect(output['company']).to have_key('acquired_on')
    expect(output['company']).to have_key('acquired_by_id')
    expect(output['company']).to have_key('ipo_on')
    expect(output['company']).to have_key('ipo_valuation')
  end

  describe 'ipo_on' do
    it 'should return the offered_on date of the initial_public_offering associated with this company' do
      today = Date.today
      ipo = InitialPublicOffering.new(offering_on: today)
      @company.stub(:initial_public_offering).and_return(ipo)
      expect(@serializer.ipo_on).to eq(today.strftime('%-m/%-d/%Y'))
    end

    it 'should return nil if this company has no initial_public_offering association' do
      @company.stub(:initial_public_offering).and_return(nil)
      expect(@serializer.ipo_on).to eq(nil)
    end
  end

  describe 'ipo_valuation' do
    it 'should return the valuation of the ipo associated with this company if present and in USD' do
      ipo = InitialPublicOffering.new(valuation_amount: 42, valuation_currency_code: 'USD')
      @company.stub(:initial_public_offering).and_return(ipo)
      expect(@serializer.ipo_valuation).to eq(42)
    end

    it 'should return nil if the ipo associated with this company is not in USD' do
      ipo = InitialPublicOffering.new(valuation_amount: 42, valuation_currency_code: 'ABC')
      @company.stub(:initial_public_offering).and_return(ipo)
      expect(@serializer.ipo_valuation).to eq(nil)
    end

    it 'should return nil if this company has no initial_public_offering association' do
      @company.stub(:initial_public_offering).and_return(nil)
      expect(@serializer.ipo_valuation).to eq(nil)
    end
  end

  describe 'investor_ids' do
    it 'should return a list of investor guids' do
      investment = Investment.new(investor_type: 'Company', investor_id: '1')
      funding_round = FundingRound.new
      funding_round.stub(:investments).and_return([investment])
      @company.stub(:funding_rounds).and_return([funding_round])

      expect(@serializer.investor_ids).to eq(['company-1'])
    end
  end

  describe 'founded_on' do
    it 'should return a formatted date' do
      @company.stub(:founded_on).and_return(Date.parse('2014-1-30'))
      expect(@serializer.founded_on).to eq('1/30/2014')
    end

    it 'should return nil if the date is nil' do
      expect(@serializer.founded_on).to be_nil
    end
  end

  describe 'status' do
    it 'should return deadpooled if deadpooled_on is set' do
      @company.stub(:deadpooled_on).and_return(Date.today)
      expect(@serializer.status).to eq('deadpooled')
    end

    it 'should return acquired if acquired by anyone' do
      @company.stub(:acquired_by).and_return([Acquisition.new])
      expect(@serializer.status).to eq('acquired')
    end

    it 'should return deadpooled if deadpooled and acquired' do
      @company.stub(:deadpooled_on).and_return(Date.today)
      @company.stub(:acquired_by).and_return([Acquisition.new])
      expect(@serializer.status).to eq('deadpooled')
    end

    it 'should return alive otherwise' do
      expect(@serializer.status).to eq('alive')
    end
  end

  describe 'acquired_on' do
    it 'should return a formatted date' do
      @company.stub(:most_recent_acquired_on).and_return(Date.parse('2014/1/28'))
      expect(@serializer.acquired_on).to eq('1/28/2014')
    end

    it 'should return a nil if the date is not set' do
      @company.stub(:most_recent_acquired_on).and_return(nil)
      expect(@serializer.acquired_on).to be_nil
    end
  end

  describe 'acquired_by_id' do
    it 'should alias most_recent_acquired_by' do
      @company.should_receive(:most_recent_acquired_by)
      @serializer.acquired_by_id
    end
  end
end
