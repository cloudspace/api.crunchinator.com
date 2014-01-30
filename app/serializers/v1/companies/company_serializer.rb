# Create the json data for a CompaniesController index call
class V1::Companies::CompanySerializer < ActiveModel::Serializer
  attributes :id, :permalink, :name, :category_id, :total_funding, :funding_rounds,
             :latitude, :longitude, :investor_ids, :founded_on
  has_many :funding_rounds, serializer: V1::Companies::NestedFundingRoundSerializer

  # @return [String] The date the company was founded formatted in m/d/y
  def founded_on
    if @object.founded_on
      @object.founded_on.strftime('%-m/%-d/%Y')
    else
      nil
    end
  end

  def investor_ids
    @object.funding_rounds.map { |fr| fr.investments.map(&:investor_guid) }.flatten.uniq
  end
end
