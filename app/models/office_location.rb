class OfficeLocation < ActiveRecord::Base
  belongs_to :tenant, polymorphic: true

  validates :tenant, presence: true

  after_create :geolocate

  def geolocate
    if country_code == 'USA' && zip_code.present?
      zip_matches = zip_code.match(/\d{5}/)
      return true if zip_matches.blank?
      zip_geo = ZipCodeGeo.find_by_zip_code(zip_matches[0])
      if zip_geo
        self.latitude = zip_geo.latitude
        self.longitude = zip_geo.longitude
        self.save
      end
    end
  end
end
