require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :company do
    permalink { FactoryGirl.generate(:unique_company_name) }
    name { FactoryGirl.generate(:unique_company_name) }
    founded_on { 1.day.ago }

    factory :company_with_category do
      category

      factory :valid_company do
        funding_rounds { |fr| [fr.association(:funding_round)] }
        office_locations { |loc| [loc.association(:headquarters)] }
      end
    end

    factory :investor do
      investments { |i| [i.association(:investment)] }
    end
  end
end
