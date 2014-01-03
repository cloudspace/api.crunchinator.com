class V1::Companies::NestedFundingRoundSerializer < ActiveModel::Serializer
  attributes :id, :raised_amount, :funded_on, :investor_ids

  def funded_on
    if @object.funded_year && @object.funded_month && @object.funded_day
      "#{@object.funded_month}/#{@object.funded_day}/#{@object.funded_year}"
    else
      nil
    end
  end

  def investor_ids
    @object.investments.collect{ |investment| "#{investment.investor_type.underscore}-#{investment.investor_id}" }
  end
end
