class V1::CompaniesController < ApplicationController

  # render all companies to json
  # include funding round and investor information
  def index
    @companies = Company.includes(:funding_rounds => :investments).includes(:office_locations).valid
    if params[:letter]
      if params[:letter][0] == '0'
        @companies = @companies.non_alpha
      else
        @companies = @companies.starts_with(params[:letter][0])
      end
    end
    @status = 200
    render :json => @companies, :status => @status, :each_serializer => V1::Companies::CompanySerializer
  end
end
