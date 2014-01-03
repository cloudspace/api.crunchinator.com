class V1::InvestorsController < ApplicationController
  # render all investors to json
  # include companies invested in
  def index
    @investors = []
    [Person, Company, FinancialOrganization].each do |klass|
      klass_investor_ids = Investment.associated_with_companies(Company.valid.pluck(:id)).where(investor_type: klass.name).pluck(:investor_id)
      if params[:letter]
        if params[:letter][0] == '0'
          @investors += klass.non_alpha.includes(:investments => {:funding_round => :company}).where(id: klass_investor_ids)
        else
          @investors += klass.starts_with(params[:letter][0]).includes(:investments => {:funding_round => :company}).where(id: klass_investor_ids)
        end
      else
        @investors += klass.includes(:investments => {:funding_round => :company}).where(id: klass_investor_ids)
      end
    end

    @investors.sort!{|x,y| x.name <=> y.name}

    @status = 200
    render :json => @investors, :status => @status, :each_serializer => V1::Investors::InvestorSerializer
  end
end
