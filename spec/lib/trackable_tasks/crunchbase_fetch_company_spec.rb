require 'spec_helper'
require Rails.root.to_s + '/lib/trackable_tasks/crunchbase_fetch_company'

describe CrunchbaseFetchCompany do
  before :each do
    @task = CrunchbaseFetchCompany.new 'sample_company'
  end

  describe 'unit test' do
    describe 'run' do
      it 'should call process_company' do
        Company.should_receive :process_company
        @task.run
      end
    end
  end

  describe 'integration test' do
    describe 'run' do
      # it 'should create a company and its associations'
    end
  end
end
