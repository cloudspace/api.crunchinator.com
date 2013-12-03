class V1::CompaniesController < ApplicationController
  def new
  end

  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def index
    @companies = Company.all
    @status = 200
    render :json => @companies, :status => @status, :each_serializer => CompanySerializer
  end

  def show
  end
end
