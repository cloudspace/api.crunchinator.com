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
  scope :funded, lambda{ joins(:funding_rounds).merge(FundingRound.funded) }

  # companies that DO NOT have positive funding in USD on any funding round
  #
  # IMPORTANT NOTE: this will return no records if funded returns an empty relation
  scope :unfunded, lambda{ where("companies.id not in (?)", funded.pluck(:id))}

  # companies that have a geolocated headquarters
  scope :geolocated, lambda{ joins(:office_locations).merge(OfficeLocation.geolocated_headquarters) }

  # companies that have no geolocated headquarters
  #
  # IMPORTANT NOTE: this will return no records if geolocated returns an empty relation
  scope :unlocated, lambda{ where("companies.id not in (?)", geolocated.pluck(:id)) }

  # companies whose headquarters is in the USA
  scope :american, lambda{ joins(:office_locations).geolocated.merge(OfficeLocation.in_usa) }

  # companies that are considered valid to the client, i.e., will be displayed
  scope :valid, lambda{ categorized.funded.geolocated.american.distinct }

  # companies that are not considered valid to the client, i.e., will not be displayed
  #
  # IMPORTANT NOTE: this will return no records if valid returns an empty relation
  scope :invalid, lambda{ where("companies.id not in (?)", valid.pluck(:id)) }

  # companies whose name attribute does not begin with an alphabetical character
  scope :non_alpha, lambda{ where("substr(companies.name,1,1) NOT IN (?)", [*('a'..'z'),*('A'..'Z')]).order('companies.name asc')}

  # companies whose name attribute begins with the specified character
  def self.starts_with(char)
    where("Upper(substr(companies.name,1,1)) = :char", {char: char.upcase}).order('companies.name asc')
  end

  def headquarters
    office_locations.headquarters.first
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
    hq = headquarters
    @latitude = hq ? hq.latitude : nil
    @longitude = hq ? hq.longitude : nil
  end

end
