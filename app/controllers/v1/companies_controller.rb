# For the v1/companies endpoints
class V1::CompaniesController < ApplicationController

  # render all companies to json
  # include funding round and investor information
  def index
    @companies = Company.includes(
      :initial_public_offering,
      :acquired_by,
      :office_locations,
      funding_rounds: :investments
    ).legit

    @status = 200
    render json: @companies, status: @status, each_serializer: V1::Companies::CompanySerializer
  end
end
