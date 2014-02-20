# Create the json data for a CategoriesController index call
class V1::Categories::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :display_name, :company_ids, :investor_ids

  # the ids of all legit companies in this category
  # cached at the instance level for performance
  def company_ids
    @cached_company_ids ||= @object.companies.legit.pluck(:id)
  end

  # compound string ids
  def investor_ids
    investments = Investment.joins(funding_round: :company).merge(FundingRound.legit.for_companies(company_ids))
    investments.map(&:investor_guid)
  end
end
