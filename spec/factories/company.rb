require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :company do
    permalink { FactoryGirl.generate(:unique_company_name) }
    name { FactoryGirl.generate(:unique_company_name) }
    founded_on { 1.day.ago }
    category
  end
end
