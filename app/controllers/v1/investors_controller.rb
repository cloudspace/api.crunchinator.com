# For the v1/investors endpoints
class V1::InvestorsController < ApplicationController

  # render all investors to json
  # include companies invested in
  def index
    letter = params[:letter] ? params[:letter][0] : nil

    @investors = [Person, Company, FinancialOrganization].reduce([]) do |memo, klass|
      investor_ids = Investment.valid.by_investor_class(klass).pluck(:investor_id)
      memo | klass.where(id: investor_ids).starts_with(letter)
    end

    @investors.sort! { |x, y| x.name <=> y.name }

    @status = 200
    render json: @investors, status: @status, each_serializer: V1::Investors::InvestorSerializer
  end
end
