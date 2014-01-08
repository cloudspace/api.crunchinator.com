require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :person, class: Person do
    firstname { FactoryGirl.generate(:unique_first_name) }
    lastname { FactoryGirl.generate(:unique_last_name) }
    permalink { FactoryGirl.generate(:guid) }
  end
end
