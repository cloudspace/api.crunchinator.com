require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :category do
    name { Faker::Company.catch_phrase }
    display_name { Faker::Company.catch_phrase }

    factory :legit_category do
      companies { |c| [c.association(:legit_company)] }
    end
  end
end
