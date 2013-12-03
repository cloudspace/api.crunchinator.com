class Person < ActiveRecord::Base
  has_many :investments, as: :investor
end
