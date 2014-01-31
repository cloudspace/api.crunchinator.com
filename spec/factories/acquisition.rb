require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :acquisition do
    acquired_company { FactoryGirl.create(:company) }
    acquiring_company { FactoryGirl.create(:company) }
    acquired_on { Date.today }
  end
end
