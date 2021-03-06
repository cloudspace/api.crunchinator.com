# An investor in other companies, an investee through funding rounds
class Company < ActiveRecord::Base
  include Investor

  has_many :funding_rounds, dependent: :destroy
  has_many :incoming_investments, through: :funding_rounds, source: :investments
  has_many :office_locations, as: :tenant, dependent: :destroy
  has_many :acquisitions, class_name: 'Acquisition', foreign_key: 'acquiring_company_id'
  has_many :acquired_by, class_name: 'Acquisition', foreign_key: 'acquired_company_id'
  has_one :initial_public_offering
  belongs_to :category

  validates :name, presence: true
  validates :permalink, uniqueness: true, presence: true

  # companies that belong to a category
  scope :categorized, -> { where.not(category_id: nil) }

  # companies that have positive funding in USD on some funding round
  scope :funded, -> { joins(:funding_rounds).merge(FundingRound.funded) }

  # companies that DO NOT have positive funding in USD on any funding round
  #
  # IMPORTANT NOTE: this will return no records if funded returns an empty relation
  scope :unfunded, -> { where.not(id: funded.pluck(:id)) }

  # companies that have a geolocated headquarters
  scope :geolocated, -> { joins(:office_locations).merge(OfficeLocation.geolocated_headquarters) }

  # companies that have a headquarters with a non-blank state_code
  scope :with_state_code, -> { joins(:office_locations).merge(OfficeLocation.headquarters.with_state_code) }

  # companies that have no geolocated headquarters
  #
  # IMPORTANT NOTE: this will return no records if geolocated returns an empty relation
  scope :unlocated, -> { where.not(id: geolocated.pluck(:id)) }

  # companies whose headquarters is in the USA according to lat/long of HQ and country code
  scope :geolocated_american, -> { joins(:office_locations).geolocated.merge(OfficeLocation.geolocated_in_usa) }

  # companies whose headquarters is in the USA according to country code
  scope :american, -> { joins(:office_locations).merge(OfficeLocation.in_usa) }

  # companies that are considered legit to the client, i.e., will be displayed
  scope :legit, -> { categorized.funded.with_state_code.american.distinct }

  # companies that are not considered legit to the client, i.e., will not be displayed
  #
  # IMPORTANT NOTE: this will return no records if legit returns an empty relation
  scope :illegit, -> { where.not(id: legit.pluck(:id)) }

  # @return [OfficeLocation] The headquarters office for the company
  def headquarters
    # note that this does not depend on the headquarters scope on the OfficeLocation model
    # to make endpoint response quicker
    #
    # Here is the traditional way to do this:
    # office_locations.headquarters.first
    #
    # Use `lazy` since we don't need to find all headquarters, just the first one
    office_locations.lazy.select { |ol| ol.headquarters }.first
  end

  # @return [Date] The most recent acquired date for the company
  delegate :date, to: :most_recent_acquired_by, prefix: true, allow_nil: true

  # @return [Fixnum] Id of company which acquired the company last
  delegate :company_id, to: :most_recent_acquired_by, prefix: true, allow_nil: true

  # @return [Fixnum] The monetary amount for which the company was last acquired, in USD
  delegate :amount, to: :most_recent_acquired_by, prefix: true, allow_nil: true

  # @return [Acquisition] The most recent acquisition where this company was acquired
  def most_recent_acquired_by
    # note that this does not depend on a scope on the Acquisitions model
    # to make endpoint response quicker
    unless instance_variables.include?(:@most_recent_acquired_by)
      @most_recent_acquired_by = acquired_by.sort { |a, b| b.acquired_on <=> a.acquired_on }.first
    end
    @most_recent_acquired_by
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
    set_lat_long_cache unless instance_variables.include?(:@latitude)
    @latitude
  end

  # Returns the longitude of this company's HQ. caches the result on the
  # instance and populates the cache for the latitude value, if needed
  #
  def longitude
    set_lat_long_cache unless instance_variables.include?(:@longitude)
    @longitude
  end

  private

  # populates the cache for both latitude and longitude on this instance
  # uses an array select on the office_locations association  to find the hq
  # rather than a query with conditions in order to take maximum advantage of
  # includes
  #
  def set_lat_long_cache
    hq = headquarters
    @latitude = hq.try(:latitude)
    @longitude = hq.try(:longitude)
  end

end
