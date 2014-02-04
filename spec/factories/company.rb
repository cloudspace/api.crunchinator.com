require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :company do
    permalink { FactoryGirl.generate(:unique_company_name) }
    name { FactoryGirl.generate(:unique_company_name) }
    founded_on { 1.day.ago }

    factory :company_with_category do
      category

      factory :valid_company do
        after(:create) do |company|
          create :headquarters, tenant: company
          funding_round = create :funding_round, company: company
          create :investment, funding_round: funding_round
        end
      end
    end
  end
end
