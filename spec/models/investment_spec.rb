require 'spec_helper'

describe Investment do
  before(:each) do
    @investment = Investment.new
  end

  describe 'associations' do
    it { expect(@investment).to belong_to :investor }
    it { expect(@investment).to belong_to :funding_round }
  end

  describe 'fields' do
    it { expect(@investment).to respond_to :investor_id }
    it { expect(@investment).to respond_to :investor_type }
    it { expect(@investment).to respond_to :funding_round_id }
  end

  describe 'scopes' do
    describe 'associated_with_financial_organizations' do
      before(:each) do
        financial_organization = FactoryGirl.create(:financial_organization)
        company = FactoryGirl.create(:company)
        funding_round = FactoryGirl.create(:funding_round, company: company)
        @associated = FactoryGirl.create(:investment, funding_round: funding_round, investor: financial_organization)
        @not_associated = FactoryGirl.create(:investment, funding_round: funding_round)
        @investments = Investment.associated_with_financial_organizations([financial_organization.id])
      end

      it 'should include investments associated with the financial_organizations' do
        expect(@investments).to include(@associated)
      end

      it 'should not include investments associated with other financial_organizations' do
        expect(@investments).not_to include(@not_associated)
      end
    end

    describe 'by_investor_type' do
      before(:each) do
        @investment = FactoryGirl.create(:investment, investor: FactoryGirl.create(:person))
      end

      it 'should match investments invested in by the specified class' do
        expect(Investment.by_investor_class(Person)).to include(@investment)
      end

      it 'should not match investments not invested in by the specified class'do
        expect(Investment.by_investor_class(Company)).not_to include(@investment)
      end
    end
  end

  describe 'instance methods' do
    describe 'investor_guid' do
      it 'should return the investor type and id' do
        investment = Investment.new(investor_type: 'Company', investor_id: 1)
        expect(investment.investor_guid).to eql('company-1')
      end

      it 'should match the investor guid' do
        investor = Person.new(id: 1)
        investment = Investment.new(investor: investor)
        expect(investment.investor_guid).to eql(investor.guid)
      end
    end
  end
end
