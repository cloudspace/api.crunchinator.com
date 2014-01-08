# For the v1/investors endpoints
class V1::InvestorsController < ApplicationController

  # render all investors to json
  # include companies invested in
  def index
    letter = params[:letter] ? params[:letter][0] : nil
    @investors = []

    [Person, Company, FinancialOrganization].each do |klass|
      klass_investor_ids = Investment.associated_with_companies(Company.valid.pluck(:id))
        .by_investor_class(klass)
        .pluck(:investor_id)
      @investors += klass.includes(investments: { funding_round: :company })
        .where(id: klass_investor_ids)
        .starts_with(letter)
    end

    @investors.sort! { |x, y| x.name <=> y.name }

    @status = 200
    render json: @investors, status: @status, each_serializer: V1::Investors::InvestorSerializer
  end
end
