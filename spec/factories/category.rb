require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :category do
    name { Faker::Company.catch_phrase }
  end
end
