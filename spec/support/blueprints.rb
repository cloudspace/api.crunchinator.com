require 'machinist/active_record'

Company.blueprint do
  permalink { "permalink #{Time.now.to_i}" }
  name { "company #{sn}" }
  category { Category.make }
end

Category.blueprint do
  name { "category #{sn}" }
end

FundingRound.blueprint do
  company
  raw_raised_amount { BigDecimal.new("1000.01") }
  raised_currency_code { 'USD' }
  funded_year { 10.days.ago.year }
  funded_month { 10.days.ago.month }
  funded_day { 10.days.ago.day }
end

Investment.blueprint do
  investor { Company.make }
  funding_round { FundingRound.make }
end

Person.blueprint do
end
