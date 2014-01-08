# Create the json data for an InvestorsController index call
class V1::Investors::InvestorSerializer < ActiveModel::Serializer
  attributes :id, :name, :investor_type, :invested_company_ids, :invested_category_ids

  # this should have the same output as investment.investor_guid
  def id
    "#{@object.class.to_s.underscore}-#{@object.id}"
  end

  # @return [String] Convert model to front end friendly version
  def investor_type
    @object.class.to_s.underscore
  end

  # @return [Array<Fixnum>] the ids of the companies in which the investor has invested
  def invested_company_ids
    @object.investments.map { |inv| inv.funding_round.company_id }.uniq
  end

  def invested_category_ids
    @object.investments.map { |inv| inv.funding_round.company.category_id }.uniq
  end
end
