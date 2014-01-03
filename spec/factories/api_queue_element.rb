require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :api_queue_element, :class => ApiQueue::Element do
    permalink { FactoryGirl.generate(:unique_company_name) }
  end
end
