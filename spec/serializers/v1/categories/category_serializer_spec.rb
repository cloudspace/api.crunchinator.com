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
        # TODO: THIS IS A CODE SMELL
        companies = FactoryGirl.build_stubbed_list(:company, 3, category: category)

        company_ids = companies.map(&:id)
        category.stub_chain(:companies, :legit, :pluck).and_return(company_ids)

        expect(hash[:company_ids]).to eq(company_ids)
      end

      it 'investor_ids' do
        # TODO: THIS IS A CODE SMELL
        investment = Investment.new(investor_type: 'Company', investor_id: '1')
        Investment.stub_chain(:joins, :merge).and_return([investment])
        expect(hash[:investor_ids]).to eql(['company-1'])
      end
    end
  end
end
