require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :acquisition do
    association :acquired_company, factory: :company
    association :acquiring_company, factory: :company
    acquired_on { Date.today }
  end
end
