require 'spec_helper'
require Rails.root.to_s + "/lib/trackable_tasks/crunchbase_company_list"

describe CrunchbaseCompanyList do
  before :each do
    @task = CrunchbaseCompanyList.new
  end

  describe 'run' do
    it 'should call get_all_companies' do
      Company.should_receive :get_all_companies
      @task.run
    end
  end
end
