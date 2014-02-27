require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :company do
    permalink { FactoryGirl.generate(:unique_company_name) }
    name { FactoryGirl.generate(:unique_company_name) }
    founded_on { 1.day.ago }
    category

    factory :legit_company do
      funding_rounds { |fr| [fr.association(:funding_round)] }
      office_locations { |loc| [loc.association(:headquarters)] }
    end

    factory :legit_company_with_investors do
      funding_rounds { |fr| [fr.association(:invested_funding_round)] }
      office_locations { |loc| [loc.association(:headquarters)] }
    end

    factory :investor do
      investments { |c| [c.association(:investment)] }
    end
  end
end
