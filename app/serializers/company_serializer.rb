# Proof of concept for the serializer system
# This is an individual record serializer so must be called with each_serializer when making multiple models into json
#
# Delete as soon as the real version is created (JH 12-3-2013)
class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :permalink, :custom_field
  has_many :funding_rounds

  def custom_field
    "If this isn't changed, then the current message will be included in the JSON response."
  end
end
