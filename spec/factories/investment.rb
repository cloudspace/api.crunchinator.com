require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :investment do
    association :investor, factory: :company
    funding_round
  end
end
