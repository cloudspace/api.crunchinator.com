FactoryGirl.define do
  factory :initial_public_offering do
    company
    valuation_amount { 42 }
    valuation_currency_code { 'USD' }
    offering_on { 10.days.ago }
    stock_symbol { "NASDAQ:#{Faker::Lorem.word.upcase}" }
  end
end
