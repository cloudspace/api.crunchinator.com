require 'machinist/active_record'

Company.blueprint do
  name { "company #{sn}" }
  category_code { "category #{sn}" }
end

FundingRound.blueprint do
  company
  raised_amount { 1000.01 }
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
