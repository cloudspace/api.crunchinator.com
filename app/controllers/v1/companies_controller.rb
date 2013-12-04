class V1::CompaniesController < ApplicationController

  # render all companies to json
  # include funding round and investor information
  def index
    @companies = Company.all
    @status = 200
    render :json => @companies, :status => @status, :each_serializer => V1::Companies::CompanySerializer
  end
end
