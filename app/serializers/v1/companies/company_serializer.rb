# Create the json data for a CompaniesController index call
class V1::Companies::CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :zip_code, :total_funding, :category_id
  has_many :funding_rounds, :serializer => V1::Companies::NestedFundingRoundSerializer
end
