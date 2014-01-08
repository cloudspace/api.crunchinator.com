# An office or headquarters for a business
# Used to determine if the company is located in the USA
class OfficeLocation < ActiveRecord::Base
  belongs_to :tenant, polymorphic: true

  validates :tenant, presence: true

  # longitude for USA coasts
  USA_LOCATION = {
    west: BigDecimal.new(-157),
    east: BigDecimal.new(-65)
  }

  # Headquarters only
  scope :headquarters, lambda {
    where(headquarters: true)
  }

  # Headquarters that have valid longitude/latitude data
  scope :geolocated_headquarters, lambda {
    headquarters
    .where('office_locations.latitude is not null AND office_locations.longitude is not null')
  }

  # Country code is USA Location is in North or South America
  # may be updated at some point to just look at lat/long for USA
  scope :in_usa, lambda {
    where(
      "office_locations.country_code = 'USA' AND office_locations.longitude BETWEEN :min_long AND :max_long",
      min_long: USA_LOCATION[:west], max_long: USA_LOCATION[:east]
    )
  }

  after_create :geolocate

  def geolocate
    if country_code == 'USA' && zip_code.present?
      zip_matches = zip_code.match(/\d{5}/)
      return true if zip_matches.blank?
      zip_geo = ZipCodeGeo.find_by_zip_code(zip_matches[0])
      if zip_geo
        self.latitude = zip_geo.latitude
        self.longitude = zip_geo.longitude
        save
      end
    end
  end
end
