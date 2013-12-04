# Proof of concept for the serializer system
# This is an individual record serializer so must be called with each_serializer when making multiple models into json
#
# Delete as soon as the real version is created (JH 12-3-2013)
class V1::Companies::CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :zip_code, :total_funding, :category_code
  has_many :funding_rounds, :serializer => V1::Companies::NestedFundingRoundSerializer

end
