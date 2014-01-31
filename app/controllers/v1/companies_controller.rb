# For the v1/companies endpoints
class V1::CompaniesController < ApplicationController

  # render all companies to json
  # include funding round and investor information
  def index
    letter = params[:letter] ? params[:letter][0] : nil

    @companies = Company.includes(:office_locations, :acquired_by, funding_rounds: :investments)
      .valid
      .starts_with(letter)

    @status = 200
    render json: @companies, status: @status, each_serializer: V1::Companies::CompanySerializer
  end
end
