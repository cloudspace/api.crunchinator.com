require 'spec_helper'

describe Acquisition do
  subject(:acquisition) { FactoryGirl.build_stubbed(:acquisition) }

  describe 'fields' do
    it { expect(acquisition).to respond_to :price_amount }
    it { expect(acquisition).to respond_to :price_currency_code }
    it { expect(acquisition).to respond_to :term_code }
    it { expect(acquisition).to respond_to :source_url }
    it { expect(acquisition).to respond_to :source_description }
    it { expect(acquisition).to respond_to :acquired_on }
    it { expect(acquisition).to respond_to :acquiring_company_id }
    it { expect(acquisition).to respond_to :acquired_company_id }
  end

  describe 'validations' do
    it { expect(acquisition).to validate_presence_of :acquired_company }
    it { expect(acquisition).to validate_presence_of :acquiring_company }
  end

  describe 'class methods' do
  end

  describe 'instance methods' do
    describe '#usd?' do
      it 'returns true if currency is USD' do
        expect(acquisition.usd?).to be_true
      end

      it 'returns false if currency is anything else' do
        acquisition.price_currency_code = nil
        expect(acquisition.usd?).to be_false
      end
    end

    describe '#date' do
      it 'returns acquired_on date' do
        expect(acquisition.date).to eq(acquisition.acquired_on)
      end
    end

    describe '#company_id' do
      it "returns the acquiring company's id" do
        expect(acquisition.company_id).to eq(acquisition.acquiring_company_id)
      end
    end

    describe '#amount' do
      it 'returns the price if currency is USD' do
        expect(acquisition.amount).to eq(acquisition.price_amount)
      end

      it 'returns 0 if currency is anything else' do
        acquisition.price_currency_code = nil
        expect(acquisition.amount).to eq(0)
      end
    end
  end
end
