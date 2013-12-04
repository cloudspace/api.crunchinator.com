class V1::Companies::NestedFundingRoundSerializer < ActiveModel::Serializer
  attributes :id, :raised_amount, :funded_on, :investors

  def investors
    @object.investments.collect { |investment| {:id => investment.investor.id, :name => investment.investor.name} }
  end
end
