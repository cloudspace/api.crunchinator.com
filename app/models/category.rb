# Type of a company
class Category < ActiveRecord::Base
  has_many :companies
  validates :name, uniqueness: true, presence: true

  # Categories associated with the passed in companies
  # @param [Array<Company>] A list of Company instances
  scope :associated_with_companies, ->(companies) { joins(:companies).where(companies: { id: companies }) }

  scope :legit, -> { joins(:companies).merge(Company.legit) }
end
