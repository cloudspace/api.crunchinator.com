class V1::Categories::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :company_ids, :investor_ids

  # the ids of all valid companies in this category
  # cached at the instance level for performance
  def company_ids
    @cached_company_ids ||= @object.companies.valid.pluck(:id)
  end

  # compound string ids
  def investor_ids
    investments = Investment.joins(:funding_round).where('funding_rounds.company_id' => company_ids, 'funding_rounds.id' => FundingRound.valid.pluck(:id)).references(:funding_rounds)
    investments.map{|i| "#{i.investor_type.underscore}-#{i.investor_id}"}
  end
end
