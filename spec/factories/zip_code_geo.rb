require Rails.root.to_s + '/spec/factories/sequences' unless FactoryGirl.sequences.any?

FactoryGirl.define do
  factory :zip_code_geo do
    latitude '100'
    longitude '100'
  end
end
