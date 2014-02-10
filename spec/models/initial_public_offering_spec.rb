require 'spec_helper'

describe InitialPublicOffering do
  before(:each) do
    @ipo = InitialPublicOffering.new
  end

  describe 'associations' do
    it { expect(@ipo).to belong_to :company }
  end

  describe 'validations' do
    it { expect(@ipo).to validate_presence_of :company_id }
  end

  describe 'fields' do
    it { expect(@ipo).to respond_to :company_id }
    it { expect(@ipo).to respond_to :valuation_amount }
    it { expect(@ipo).to respond_to :valuation_currency_code }
    it { expect(@ipo).to respond_to :offering_on }
    it { expect(@ipo).to respond_to :stock_symbol }
  end

  describe 'scopes' do
  end

  describe 'instance_methods' do
    describe 'usd_valuation' do
      it 'should return the valuation_amount if the valuation_currency_code is "USD"' do
        @ipo.assign_attributes(valuation_amount: 42, valuation_currency_code: 'USD')
        expect(@ipo.usd_valuation).to eq(42)
      end

      it 'should be nil if there is no valuation_currency_code' do
        @ipo.assign_attributes(valuation_amount: 42, valuation_currency_code: nil)
        expect(@ipo.usd_valuation).to eq(nil)
      end

      it 'should be nil if the valuation_currency_code is not "USD"' do
        @ipo.assign_attributes(valuation_amount: 42, valuation_currency_code: 'ABC')
        expect(@ipo.usd_valuation).to eq(nil)
      end
    end
  end
end
