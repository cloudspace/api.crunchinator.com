# An individual not associated with a company
# Can be an investor
class Person < ActiveRecord::Base
  include Investor

  has_many :office_locations, as: :tenant, dependent: :destroy

  validates :permalink, uniqueness: true, presence: true

  # @return [String] - returns a name value for the person it is called on
  # it will return 'Unknown Name' if the Person has no name values
  def name
    fullname || firstname || lastname || 'Unknown Name'
  end

  def fullname
    "#{firstname} #{lastname}" if fullname?
  end

  def fullname?
    firstname? && lastname?
  end
end
