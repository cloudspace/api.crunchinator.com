FactoryGirl.define do
  sequence :guid do |n|
    n.to_s
  end

  sequence :unique_email do |n|
    "#{Faker::Name.last_name.downcase}#{n}@api.crunchinator.com"
  end

  sequence :unique_first_name do |n|
    "#{Faker::Name.first_name} #{n}"
  end

  sequence :unique_last_name do |n|
    "#{Faker::Name.last_name} #{n}"
  end

  sequence :unique_company_name do |n|
    "#{Faker::Company.name} #{n}"
  end
end
