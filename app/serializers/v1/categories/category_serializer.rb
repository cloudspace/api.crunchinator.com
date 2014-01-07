class V1::Categories::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :company_ids, :investor_ids

  # the ids of all valid companies in this category
  # cached at the instance level for performance
  def company_ids
    @cached_company_ids ||= @object.companies.valid.pluck(:id)
  end

  # compound string ids
  def investor_ids
    investments = Investment.joins(:funding_round).merge(FundingRound.valid.for_companies(company_ids))
    investments.map(&:investor_guid)
  end
end
