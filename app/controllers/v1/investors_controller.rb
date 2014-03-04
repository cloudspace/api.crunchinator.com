# For the v1/investors endpoints
class V1::InvestorsController < ApplicationController

  # render all investors to json
  # include companies invested in
  def index
    @investors = [Person, Company, FinancialOrganization].reduce([]) do |memo, klass|
      investor_ids = Investment.legit.by_investor_class(klass).pluck(:investor_id)
      memo | klass.includes(:investments).where(id: investor_ids)
    end

    @investors.sort! { |x, y| x.name <=> y.name }

    @status = 200
    render json: @investors, status: @status, each_serializer: V1::Investors::InvestorSerializer
  end
end
