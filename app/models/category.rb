# Type of a company
class Category < ActiveRecord::Base
  has_many :companies
  validates :name, uniqueness: true, presence: true

  # Categories associated with at least one legit company
  scope :legit, -> { joins(:companies).merge(Company.legit) }
end
