require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :company do
    permalink { FactoryGirl.generate(:unique_company_name) }
    name { FactoryGirl.generate(:unique_company_name) }
    founded_on { 1.day.ago }
    category

    factory :valid_company do
      funding_rounds { |c| [c.association(:funding_round)] }
      office_locations { |c| [c.association(:headquarters)] }
    end

    factory :investor do
      investments { |c| [c.association(:investment)] }
    end
  end
end
