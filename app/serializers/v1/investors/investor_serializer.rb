# Create the json data for an InvestorsController index call
class V1::Investors::InvestorSerializer < ActiveModel::Serializer
  attributes :id, :name, :investor_type, :zip_code

  # @return [String] Convert model to front end friendly version
  def investor_type
    @object.class.to_s.underscore
  end

  # Companies have zip codes, people don't
  # @return [String] The zip code if the method exists
  def zip_code
    if @object.respond_to? :zip_code
      @object.zip_code
    else
      ""
    end
  end
end
