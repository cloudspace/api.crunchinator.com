# An office or headquarters for a business
# Used to determine if the company is located in the USA
class OfficeLocation < ActiveRecord::Base
  belongs_to :tenant, polymorphic: true

  validates :tenant, presence: true

  # longitude for USA coasts
  USA_LOCATION = {
    west: -157,
    east: -65
  }

  # Headquarters only
  scope :headquarters, lambda {
    where(headquarters: true)
  }

  # Headquarters that have legit longitude/latitude data
  scope :geolocated_headquarters, lambda {
    headquarters.where.not(latitude: nil, longitude: nil)
  }

  # Country code is USA Location is in North or South America
  # may be updated at some point to just look at lat/long for USA
  scope :in_usa, lambda {
    where(country_code: 'USA', longitude: USA_LOCATION[:west]..USA_LOCATION[:east])
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
