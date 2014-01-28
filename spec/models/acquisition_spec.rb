require 'spec_helper'

describe Acquisition do
  before(:each) do
    @acquisition = Acquisition.new
  end

  describe 'fields' do
    it { expect(@acquisition).to respond_to :price_amount }
    it { expect(@acquisition).to respond_to :price_currency_code }
    it { expect(@acquisition).to respond_to :term_code }
    it { expect(@acquisition).to respond_to :source_url }
    it { expect(@acquisition).to respond_to :source_description }
    it { expect(@acquisition).to respond_to :acquired_on }
    it { expect(@acquisition).to respond_to :acquiring_company_id }
    it { expect(@acquisition).to respond_to :acquired_company_id }
  end

  describe 'validations' do
    it { expect(@acquisition).to validate_presence_of :acquired_company }
    it { expect(@acquisition).to validate_presence_of :acquiring_company }
  end

  describe 'class methods' do
  end

  describe 'instance methods' do
  end
end
