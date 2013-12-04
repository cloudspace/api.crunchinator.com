class V1::InvestorsController < ApplicationController
  # render all investors to json
  # include companies invested in
  def index
    @investors = []
    [Person, Company].each do |type|
      @investors += type.joins(:investments).merge(Investment.associated_with_companies(Company.pluck(:id)))
    end

    @status = 200
    render :json => @investors, :status => @status, :each_serializer => V1::Investors::InvestorSerializer
  end
end
