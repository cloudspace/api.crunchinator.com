require 'spec_helper'

describe V1::Investors::InvestorSerializer do
  let(:investor) { FactoryGirl.build_stubbed(:investor) }
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

      it 'permalink' do
        expect(hash[:permalink]).to eq(investor.permalink)
      end

      describe 'invested_category_ids' do
        let(:investor) { FactoryGirl.create(:investor) }

        it 'returns the ids of the companies that the investor has invested in' do
          company_ids = investor.investments.map { |i| i.funding_round.company_id }

          expect(hash[:invested_company_ids]).to eq(company_ids)
        end
      end

      describe 'invested_category_ids' do
        let(:investor) { FactoryGirl.create(:investor) }

        it 'returns the ids of the categories of the companies that the investor has invested in' do
          category_ids = investor.investments.map { |i| i.funding_round.company.category_id }

          expect(hash[:invested_category_ids]).to eq(category_ids)
        end
      end
    end
  end
end
