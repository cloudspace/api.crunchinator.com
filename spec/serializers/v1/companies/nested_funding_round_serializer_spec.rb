require 'spec_helper'

describe V1::Companies::NestedFundingRoundSerializer do
  let(:funding_round) { FactoryGirl.build_stubbed(:funding_round) }
  let(:serializer) { V1::Companies::NestedFundingRoundSerializer.new(funding_round) }

  describe 'json output' do
    subject(:json) { serializer.as_json }

    it { should have_key :nested_funding_round }

    describe 'has properties' do
      subject(:hash) { json[:nested_funding_round] }

      it 'id' do
        expect(hash[:id]).to eq(funding_round.id)
      end

      it 'raised_amount' do
        expect(hash[:raised_amount]).to eq(funding_round.raised_amount)
      end

      it 'funded_on' do
        expect(hash[:funded_on]).to eq(funding_round.funded_on.strftime('%-m/%-d/%Y'))
      end

      it 'investor_ids' do
        investments = FactoryGirl.build_stubbed_list(:investment, 3)
        funding_round.stub(investments: investments)

        investor_ids = investments.map(&:investor_guid)

        expect(hash[:investor_ids]).to eq(investor_ids)
      end
    end
  end
end
