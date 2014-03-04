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

  # Those have a state_code
  scope :with_state_code, -> { where.not(state_code: [nil, '']) }

  # Country code is USA Location is in North or South America according to lat/long
  scope :geolocated_in_usa, lambda {
    where(
      where(country_code: 'USA', longitude: USA_LOCATION[:west]..USA_LOCATION[:east])
    )
  }

  # Country code is 'USA'
  scope :in_usa, -> { where(country_code: 'USA') }

  after_create :geolocate

  def geolocate
    if country_code == 'USA' && zip_code?
      zip = zip_code[/\d{5}/]
      return true unless zip

      zip_geo = ZipCodeGeo.find_by_zip_code(zip)
      if zip_geo
        self.latitude = zip_geo.latitude
        self.longitude = zip_geo.longitude
        save
      end
    end
  end
end
