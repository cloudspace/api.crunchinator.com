require 'spec_helper'

describe Investment do
  describe "associations" do
    before(:each) do
      @investment = Investment.new
    end
    subject { @investment }
    
    it { should belong_to :investor }
    it { should belong_to :funding_round }
  end

  describe "fields" do
    it { should respond_to :investor_id }
    it { should respond_to :investor_type }
    it { should respond_to :funding_round_id}
  end

  describe 'scopes' do
    describe 'associated_with_companies' do
      before(:each) do
        company = Company.make!
        funding_round = FundingRound.make!(company: company)
        @associated = Investment.make!(funding_round: funding_round)
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
    
    describe 'associated_with_financial_organizations' do
      before(:each) do
        financial_organization = FinancialOrganization.make!
        company = Company.make!
        funding_round = FundingRound.make!(company: company)
        @associated = Investment.make!(funding_round: funding_round, investor: financial_organization)
        @not_associated = Investment.make!(funding_round: funding_round)
        @investments = Investment.associated_with_financial_organizations([financial_organization.id])
      end

      it 'should include investments associated with the financial_organizations' do
        expect(@investments).to include(@associated)
      end

      it 'should not include investments associated with other financial_organizations' do
        expect(@investments).not_to include(@not_associated)
      end
    end

  end
end
