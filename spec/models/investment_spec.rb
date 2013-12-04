require 'spec_helper'

describe Investment do
  describe 'scopes' do
    describe 'associated_with_companies' do
      before(:each) do
        company = Company.make!
        funding_round = FundingRound.make!(:company => company)
        @associated = Investment.make!(:funding_round => funding_round)
        @not_associated = Investment.make!

        @investments = Investment.associated_with_companies([company.id])
      end

      it 'should include investments associated with the companies' do
        expect(@investments).to include(@associated)
      end

      it 'should not include investments associated with other companies' do
        expect(@investments).not_to include(@not_associated)
      end
    end
  end

  describe 'class methods' do
    describe 'create investor' do
      it 'should create a new Investment'
      it 'should associate an Investment with an Investor'
      it 'should return a new Investment'
    end
  end
end
