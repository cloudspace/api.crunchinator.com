# An investor in other companies, an investee through funding rounds
class Company < ActiveRecord::Base
  include Investor

  has_many :funding_rounds, dependent: :destroy
  has_many :investments, as: :investor, dependent: :destroy
  has_many :office_locations, as: :tenant, dependent: :destroy

  has_many :acquisitions, class_name: 'Acquisition', foreign_key: 'acquiring_company_id'
  has_many :acquired_by, class_name: 'Acquisition', foreign_key: 'acquired_company_id'

  belongs_to :category

  validates :name, uniqueness: true, presence: true
  validates :permalink, uniqueness: true, presence: true

  # companies that belong to a category
  scope :categorized, -> { where('companies.category_id is not null') }

  # companies that have positive funding in USD on some funding round
  scope :funded, -> { joins(:funding_rounds).merge(FundingRound.funded) }

  # companies that DO NOT have positive funding in USD on any funding round
  #
  # IMPORTANT NOTE: this will return no records if funded returns an empty relation
  scope :unfunded, -> { where('companies.id not in (?)', funded.pluck(:id)) }

  # companies that have a geolocated headquarters
  scope :geolocated, -> { joins(:office_locations).merge(OfficeLocation.geolocated_headquarters) }

  # companies that have no geolocated headquarters
  #
  # IMPORTANT NOTE: this will return no records if geolocated returns an empty relation
  scope :unlocated, -> { where('companies.id not in (?)', geolocated.pluck(:id)) }

  # companies whose headquarters is in the USA
  scope :american, -> { joins(:office_locations).geolocated.merge(OfficeLocation.in_usa) }

  # companies that are considered valid to the client, i.e., will be displayed
  scope :valid, -> { categorized.funded.geolocated.american.distinct }

  # companies that are not considered valid to the client, i.e., will not be displayed
  #
  # IMPORTANT NOTE: this will return no records if valid returns an empty relation
  scope :invalid, -> { where('companies.id not in (?)', valid.pluck(:id)) }

  # companies whose name attribute does not begin with an alphabetical character
  scope :starts_with_non_alpha, lambda {
    where(
      'substr(companies.name,1,1) NOT IN (?)',
      [*('a'..'z'), *('A'..'Z')]
    ).order('companies.name asc')
  }

  # companies whose name attribute begins with the specified character
  scope :starts_with_letter, lambda { |char|
    where(
      'Upper(substr(companies.name,1,1)) = :char',
      char: char.upcase
    ).order('companies.name asc')
  }

  def headquarters
    # note that this does not depend on the headquarters scope on the OfficeLocation model
    # to make endpoint response quicker
    #
    # Here is the traditional way to do this:
    # office_locations.headquarters.first
    office_locations.select { |ol| ol.headquarters }.first
  end

  # Concerned about how slow this will be
  # this is only needed for the front end and it has all of the data to calculate it
  # may need to denormalize the value or let the front end calculate it on it's own
  def total_funding
    funding_rounds.to_a.sum { |fr| fr.raised_amount }.to_i
  end

  # Returns the latitude of this company's HQ. caches the result on the
  # instance and populates the cache for the longitude value, if needed
  #
  def latitude
    instance_variables.include?(:@latitude) ? @latitude : (set_lat_long_cache && @latitude)
  end

  # Returns the longitude of this company's HQ. caches the result on the
  # instance and populates the cache for the latitude value, if needed
  #
  def longitude
    instance_variables.include?(:@longitude) ? @longitude : (set_lat_long_cache && @longitude)
  end

  private

  # populates the cache for both latitude and longitude on this instance
  # uses an array select on the office_locations association  to find the hq
  # rather than a query with conditions in order to take maximum advantage of
  # includes
  #
  def set_lat_long_cache
    hq = headquarters
    @latitude = hq ? hq.latitude : nil
    @longitude = hq ? hq.longitude : nil
  end

end
