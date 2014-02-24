require 'spec_helper'

describe V1::Categories::CategorySerializer do
  let(:category) { FactoryGirl.build_stubbed(:category) }
  let(:serializer) { V1::Categories::CategorySerializer.new(category) }

  describe 'json output' do
    subject(:json) { serializer.as_json }

    it { should have_key :category }

    describe 'has properties' do
      subject(:hash) { json[:category] }

      it 'id' do
        expect(hash[:id]).to eq(category.id)
      end

      it 'name' do
        expect(hash[:name]).to eq(category.name)
      end

      it 'display_name' do
        expect(hash[:display_name]).to eq(category.display_name)
      end

      it 'company_ids' do
        company = FactoryGirl.create(:legit_company, category: category)

        expect(hash[:company_ids]).to eq([company.id])
      end

      it 'investor_ids' do
        company = FactoryGirl.create(:legit_company, category: category)
        investor_guids = company.incoming_investments.map(&:investor_guid)

        expect(hash[:investor_ids]).to eql(investor_guids)
      end
    end
  end
end
