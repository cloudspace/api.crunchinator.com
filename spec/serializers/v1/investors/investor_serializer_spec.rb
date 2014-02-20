require 'spec_helper'

describe V1::Investors::InvestorSerializer do
  let(:investor) { FactoryGirl.build_stubbed(:company) }
  let(:serializer) { V1::Investors::InvestorSerializer.new(investor) }

  describe 'json output' do
    subject(:json) { serializer.as_json }

    it { should have_key :investor }

    describe 'has properties' do
      subject(:hash) { json[:investor] }

      it 'id' do
        expect(hash[:id]).to eq(investor.guid)
      end

      it 'name' do
        expect(hash[:name]).to eq(investor.name)
      end

      it 'investor_type' do
        expect(hash[:investor_type]).to eq(investor.class.to_s.underscore)
      end

      it 'invested_company_ids' do
        investments = FactoryGirl.build_stubbed_list(:investment, 3, investor: investor)
        investor.stub(investments: investments)

        company_ids = investments.map { |i| i.funding_round.company_id }

        expect(hash[:invested_company_ids]).to eq(company_ids)
      end

      it 'invested_category_ids' do
        investments = FactoryGirl.build_stubbed_list(:investment, 3, investor: investor)
        investor.stub(investments: investments)

        category_ids = investments.map do |i|
          i.funding_round.company.category_id
        end

        expect(hash[:invested_category_ids]).to eq(category_ids)
      end
    end
  end
end
