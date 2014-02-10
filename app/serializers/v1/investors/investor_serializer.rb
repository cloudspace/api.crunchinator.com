# Create the json data for an InvestorsController index call
class V1::Investors::InvestorSerializer < ActiveModel::Serializer
  attributes :id, :name, :investor_type, :invested_company_ids, :invested_category_ids

  # @return [String] delegates the guid to id for the front end
  def id
    @object.guid
  end

  # @return [String] Convert model to front end friendly version
  def investor_type
    @object.class.to_s.underscore
  end

  # @return [Array<Fixnum>] the ids of the companies in which the investor has invested
  def invested_company_ids
    @object.investments.map { |inv| inv.funding_round.company_id }.uniq
  end

  # @return [Array<Fixnum>] the ids of the categories of the companies in which the investor has invested
  def invested_category_ids
    @object.investments.map { |inv| inv.funding_round.company.category_id }.uniq
  end
end
