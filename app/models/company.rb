class Company < ActiveRecord::Base
  has_many :funding_rounds, :dependent => :destroy
  has_many :investments, :as => :investor, :dependent => :destroy
  has_many :office_locations, :as => :tenant, :dependent => :destroy
  belongs_to :category

  validates :name, uniqueness: true, presence: true
  validates :permalink, uniqueness: true, presence: true

  # companies that belong to a category
  scope :categorized, lambda{ where('companies.category_id is not null') }

  # companies that have positive funding in USD on some funding round
  scope :funded, lambda{ joins(:funding_rounds).where("funding_rounds.raised_currency_code = 'USD' AND funding_rounds.raw_raised_amount is not null AND funding_rounds.raw_raised_amount > 0")}

  # companies that DO NOT have positive funding in USD on any funding round
  scope :unfunded, lambda{ where("companies.id not in (?)", funded.pluck(:id))}

  # companies that have a geolocated headquarters
  scope :geolocated, lambda{ joins(:office_locations).where("office_locations.headquarters = 't' AND office_locations.latitude is not null AND office_locations.longitude is not null").references(:office_locations) }

  # companies that have no geolocated headquarters
  scope :unlocated, lambda{ where("companies.id not in (?)", geolocated.pluck(:id)) }

  # longitude for USA coasts
  USA_WEST_COAST = BigDecimal.new(-157)
  USA_EAST_COAST = BigDecimal.new(-65)
  # companies whose headquarters is in the USA
  scope :american, lambda{ geolocated.where("office_locations.country_code = 'USA' AND office_locations.longitude BETWEEN :min_long AND :max_long", {min_long: USA_WEST_COAST, max_long: USA_EAST_COAST}) }

  # companies that are considered valid to the client, i.e., will be displayed
  scope :valid, lambda{ categorized.funded.geolocated.american.distinct }

  # companies that are not considered valid to the client, i.e., will not be displayed
  scope :invalid, lambda{ where("companies.id not in (?)", valid.pluck(:id)) }

  # companies whose name attribute does not begin with an alphabetical character
  scope :non_alpha, lambda{ where("substr(companies.name,1,1) NOT IN (?)", [*('a'..'z'),*('A'..'Z')]).order('companies.name asc')}

  # companies whose name attribute begins with the specified character
  scope :starts_with, lambda { |char| where("Upper(substr(companies.name,1,1)) = :char", {char: char.upcase}).order('companies.name asc') }

  def headquarters
    office_locations.where(headquarters: true).first
  end

  def zip_code
    if(headquarters)
      headquarters.zip_code
    else
      ""
    end
  end

  # Concerned about how slow this will be
  # this is only needed for the front end and it has all of the data to calculate it
  # may need to denormalize the value or let the front end calculate it on it's own
  def total_funding
    funding_rounds.to_a.sum{|fr| fr.raised_amount}
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
    hq = office_locations.select{|ol| ol.headquarters == true}.first
    @latitude = hq ? hq.latitude : nil
    @longitude = hq ? hq.longitude : nil
  end

end
