# A type of investor
# Not exactly sure how it differs from a company
class FinancialOrganization < ActiveRecord::Base
  include Investor

  has_many :office_locations, as: :tenant

  validates :permalink, uniqueness: true, presence: true

  def headquarters
    office_locations.where(headquarters: true).first
  end
end
