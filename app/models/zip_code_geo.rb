require 'csv'

# Stores lat/long per zip code in the US
class ZipCodeGeo < ActiveRecord::Base

  # Load the zip codes from the seeds file
  #
  # @param file The file to look at.
  #
  def self.import_from_csv(file = File.new("#{Rails.root}/seed/zipcode.csv", 'r'))
    CSV.foreach(file.path, headers: true) do |row|
      begin
        ZipCodeGeo.where(:zip_code => row['zip']).first_or_create do |zcg|
          zcg.city = row['city']
          zcg.state = row['state']
          zcg.latitude = BigDecimal.new(row['latitude'])
          zcg.longitude = BigDecimal.new(row['longitude'])
        end
      rescue
        next
      end
    end
  end
end
