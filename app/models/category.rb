class Category < ActiveRecord::Base
  has_many :companies
  validates :name, :uniqueness => true
end
