require 'spec_helper'

describe V1::CompaniesController do
  describe 'index' do
    it "should return json" do
      post :index
      response.class.should equal(ActionController::TestResponse)
    end
  end
end
