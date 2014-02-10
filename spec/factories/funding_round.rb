require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :funding_round do
    company
    raw_raised_amount { BigDecimal.new('1000.01') }
    raised_currency_code { 'USD' }
    funded_on { 10.days.ago }
    sequence :crunchbase_id

    factory :invested_funding_round do
      after(:create) do |funding_round|
        FactoryGirl.create(:investment, funding_round: funding_round)
      end
    end

    factory :unfunded_funding_round do
      raw_raised_amount { BigDecimal.new('0') }
    end
  end
end
