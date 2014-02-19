require 'spec_helper'

describe V1::Companies::CompanySerializer do
  let(:company) { FactoryGirl.build(:company, id: rand(100)) }
  let(:serializer) { V1::Companies::CompanySerializer.new(company) }

  describe 'json output' do
    subject(:json) { serializer.as_json }

    it { should have_key :company }

    describe 'has property' do
      subject(:hash) { json[:company] }

      it 'id' do
        expect(hash[:id]).to eq(company.id)
      end

      it 'name' do
        expect(hash[:name]).to eq(company.name)
      end

      it 'category_id' do
        expect(hash[:category_id]).to eq(company.category_id)
      end

      it 'investor_ids' do
        investor = FactoryGirl.create(:investor)
        FactoryGirl.create(:funding_round, company: company, investments: investor.investments)

        expect(hash[:investor_ids]).to eq([investor.guid])
      end

      it 'total_funding' do
        fr = FactoryGirl.create(:funding_round, company: company)
        expect(hash[:total_funding]).to eq(fr.raised_amount.to_i)
      end

      describe 'location' do
        let(:headquarters) { FactoryGirl.create(:headquarters, tenant: company) }

        it 'latitude' do
          latitude = headquarters.latitude
          expect(hash[:latitude]).to eq(latitude)
        end

        it 'longitude' do
          longitude = headquarters.longitude
          expect(hash[:longitude]).to eq(longitude)
        end
      end

      # Tested by NestedFundingRoundSerializer
      it { should have_key :funding_rounds }

      describe 'ipo_on' do
        let(:ipo) do
          FactoryGirl.build(:initial_public_offering, company: company).tap do |ipo|
            company.stub(initial_public_offering: ipo)
          end
        end

        it 'returns date of IPO' do
          date = ipo.offering_on.strftime('%-m/%-d/%Y')
          expect(hash[:ipo_on]).to eq(date)
        end

        it 'returns nil if no IPO' do
          company.stub(initial_public_offering: nil)
          expect(hash[:ipo_on]).to be_nil
        end
      end

      describe 'ipo_valuation' do
        let(:ipo) do
          FactoryGirl.build(:initial_public_offering, company: company).tap do |ipo|
            company.stub(initial_public_offering: ipo)
          end
        end

        it 'returns the valuation of the IPO' do
          valuation = ipo.valuation_amount
          expect(hash[:ipo_valuation]).to eq(valuation)
        end

        it 'returns nil if the IPO is not in USD' do
          ipo = FactoryGirl.build(:initial_public_offering, valuation_currency_code: 'ABC')
          company.stub(initial_public_offering: ipo)
          expect(hash[:ipo_valuation]).to be_nil
        end

        it 'returns nil if no IPO' do
          company.stub(initial_public_offering: nil)
          expect(hash[:ipo_valuation]).to be_nil
        end
      end

      describe 'founded_on' do
        it 'returns a formatted date' do
          expect(hash[:founded_on]).to eq(company.founded_on.strftime('%-m/%-d/%Y'))
        end

        it 'returns nil if the date is nil' do
          company.stub(founded_on: nil)
          expect(hash[:founded_on]).to be_nil
        end
      end

      describe 'status' do
        it 'returns deadpooled if company is dead' do
          company.stub(deadpooled_on: Date.today)
          expect(hash[:status]).to eq('deadpooled')
        end

        it 'returns acquired if acquired by anyone' do
          FactoryGirl.create(:acquisition, acquired_company: company)
          expect(hash[:status]).to eq('acquired')
        end

        it 'returns deadpooled if deadpooled and acquired' do
          company.stub(deadpooled_on: Date.today)
          FactoryGirl.create(:acquisition, acquired_company: company)
          expect(hash[:status]).to eq('deadpooled')
        end

        it 'returns IPOed if IPOed' do
          FactoryGirl.create(:initial_public_offering, company: company)
          expect(hash[:status]).to eq('IPOed')
        end

        it 'returns deadpooled if deadpooled and IPOed' do
          company.stub(deadpooled_on: Date.today)
          FactoryGirl.create(:initial_public_offering, company: company)
          expect(hash[:status]).to eq('deadpooled')
        end

        it 'returns alive otherwise' do
          expect(hash[:status]).to eq('alive')
        end
      end

      describe 'acquired_on' do
        it 'returns a formatted date' do
          company.stub(most_recent_acquired_on: Date.parse('2014/1/28'))
          expect(hash[:acquired_on]).to eq('1/28/2014')
        end

        it 'returns nil if the date is not set' do
          company.stub(most_recent_acquired_on: nil)
          expect(hash[:acquired_on]).to be_nil
        end
      end

      it 'acquired_by_id' do
        company.stub(most_recent_acquired_by: 1)
        expect(hash[:acquired_by_id]).to eq(company.most_recent_acquired_by)
      end

      describe 'state_code' do
        it 'returns the state code of the headquarters' do
          headquarters = FactoryGirl.create(:headquarters, tenant: company, state_code: 'FOO')
          expect(hash[:state_code]).to eq(headquarters.state_code)
        end

        it 'returns nil if no headquarters' do
          company.stub(headquarters: nil)
          expect(hash[:state_code]).to be_nil
        end
      end
    end
  end
end
