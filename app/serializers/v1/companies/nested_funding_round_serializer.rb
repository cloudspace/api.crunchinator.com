# Funding rounds for companies on the companies index endpoint
class V1::Companies::NestedFundingRoundSerializer < ActiveModel::Serializer
  attributes :id, :raised_amount, :funded_on, :investor_ids

  def funded_on
    if @object.funded_on.present?
      @object.funded_on.strftime('%-m/%-d/%Y')
    else
      nil
    end
  end

  def investor_ids
    @object.investments.map { |investment| investment.investor_guid }
  end
end
