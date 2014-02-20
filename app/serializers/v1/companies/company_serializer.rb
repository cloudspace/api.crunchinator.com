# Create the json data for a CompaniesController index call
class V1::Companies::CompanySerializer < ActiveModel::Serializer
  attributes :id, :permalink, :name, :category_id, :total_funding, :funding_rounds,
             :latitude, :longitude, :investor_ids, :status, :founded_on, :acquired_on,
             :acquired_value, :acquired_by_id, :ipo_valuation, :ipo_on, :state_code
  has_many :funding_rounds, serializer: V1::Companies::NestedFundingRoundSerializer

  # @return [Array<String>] the guids of all investors in this company
  def investor_ids
    @object.funding_rounds.map { |fr| fr.investments.map(&:investor_guid) }.flatten.uniq
  end

  # @return [String, nil] a string representing the ipo date, if defined
  def ipo_on
    @object.initial_public_offering.try(:offering_on).try(:strftime, '%-m/%-d/%Y')
  end

  # @return [FixNum, nil] an integer representing the ipo valuation in USD, or nil if not present or not in USD
  def ipo_valuation
    @object.initial_public_offering.try(:usd_valuation)
  end

  # @return [String] The date the company was founded formatted in m/d/y
  def founded_on
    @object.founded_on.try(:strftime, '%-m/%-d/%Y')
  end

  # Whether the company is deadpooled, acquired, or still alive
  # The order of these checks is important because a company can be both deadpooled and acquired
  #
  # @return [String] The status of the company
  def status
    if @object.deadpooled_on
      'deadpooled'
    elsif @object.acquired_by.any?
      'acquired'
    elsif @object.initial_public_offering.present?
      'IPOed'
    else
      'alive'
    end
  end

  # renames and formats the most_recent_acquired_on method
  def acquired_on
    @object.most_recent_acquired_by_date.try(:strftime, '%-m/%-d/%Y')
  end

  # renames and formats the most_recent_acquired_on method
  def acquired_value
    @object.most_recent_acquired_by_amount
  end

  # renames the most_recent_acquired_by method
  def acquired_by_id
    @object.most_recent_acquired_by_company_id
  end

  # the state code for this company's headquarters
  def state_code
    @object.headquarters.try(:state_code)
  end
end
