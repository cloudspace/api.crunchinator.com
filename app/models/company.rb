class Company < ActiveRecord::Base
  has_many :funding_rounds
  has_many :investments, as: :investor
end
