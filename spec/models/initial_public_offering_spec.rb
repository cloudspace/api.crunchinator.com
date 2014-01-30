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
  end
end
