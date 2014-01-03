require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :financial_organization do
    permalink { FactoryGirl.generate(:unique_company_name) }
  end
end
