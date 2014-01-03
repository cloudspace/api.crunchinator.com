require 'csv'
class ZipCodeGeo < ActiveRecord::Base
  def self.import_from_csv(file = File.new("#{Rails.root}/seed/zipcode.csv", 'r'))
    self.delete_all
    CSV.foreach(file.path, headers: true) do |row|
      begin
        attributes = row.to_hash
        attributes['zip_code'] = attributes.delete('zip')
        attributes.delete('timezone')
        attributes.delete('dst')
        attributes['latitude'] = BigDecimal.new(attributes['latitude'])
        attributes['longitude'] = BigDecimal.new(attributes['longitude'])
        self.create! attributes
      rescue => e
        next
      end
    end
  end
end
