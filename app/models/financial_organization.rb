# A type of investor
# Not exactly sure how it differs from a company
class FinancialOrganization < ActiveRecord::Base
  has_many :investments, as: :investor
  has_many :office_locations, as: :tenant

  validates :permalink, uniqueness: true, presence: true

  # finanial_organizations whose name attribute does not begin with an alphabetical character
  scope :non_alpha, lambda {
    where(
      'substr(financial_organizations.name,1,1) NOT IN (?)',
      [*('a'..'z'), *('A'..'Z')]
    ).order('financial_organizations.name asc')
  }

  # finanial_organizations whose name attribute begins with the specified character
  scope :starts_with, lambda { |char|
    where(
      'Upper(substr(financial_organizations.name,1,1)) = :char',
      char: char.upcase
    ).order('financial_organizations.name asc')
  }

  def headquarters
    office_locations.where(headquarters: true).first
  end
end
