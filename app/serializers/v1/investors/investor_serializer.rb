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

end
