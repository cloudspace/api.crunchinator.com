# Create the json data for a CompaniesController index call
class V1::Companies::CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :category_id, :total_funding, :funding_rounds, :latitude, :longitude, :investor_ids
  has_many :funding_rounds, :serializer => V1::Companies::NestedFundingRoundSerializer

  def investor_ids
    @object.funding_rounds.map{|fr| fr.investments.map{|i| "#{i.investor_type.underscore}-#{i.investor_id}" }}.uniq
  end
end
