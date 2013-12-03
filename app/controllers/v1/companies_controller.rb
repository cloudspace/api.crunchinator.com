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
    result = @companies.map{|company| company.to_json }
    render :json => result, :status => @status
  end

  def show
  end
end
