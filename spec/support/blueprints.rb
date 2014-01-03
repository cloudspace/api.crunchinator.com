require 'machinist/active_record'

ApiQueue::Element.blueprint do
  permalink { "permalink #{Time.now.to_i}"+('a'..'z').to_a.sample+(1..1000).to_a.sample.to_s }
end

Company.blueprint do
  permalink { "permalink #{Time.now.to_i}"+('a'..'z').to_a.sample+(1..1000).to_a.sample.to_s }
  name { "company #{sn}" }
  category { Category.make }
end

Category.blueprint do
  name { "category #{sn}" }
end

FinancialOrganization.blueprint do
  permalink { "permalink #{Time.now.to_i}"+('a'..'z').to_a.sample+(1..1000).to_a.sample.to_s }  
end

FundingRound.blueprint do
  company
  raw_raised_amount { BigDecimal.new("1000.01") }
  raised_currency_code { 'USD' }
  funded_year { 10.days.ago.year }
  funded_month { 10.days.ago.month }
  funded_day { 10.days.ago.day }
  crunchbase_id  { "123" }
end

Investment.blueprint do
  investor { Company.make }
  funding_round { FundingRound.make }
end

Person.blueprint do
end
