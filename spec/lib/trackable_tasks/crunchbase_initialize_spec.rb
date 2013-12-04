require 'spec_helper'
require Rails.root.to_s + '/lib/trackable_tasks/crunchbase_initialize'

describe CrunchbaseInitialize do
  before :each do
    @task = CrunchbaseInitialize.new
  end

  describe 'unit test' do
    describe 'run' do
    end
  end

  describe 'integration test' do
    describe 'run' do
      it 'should import all companies and from service'
      it 'should access s3 for data if called with service'
      it 'should access crunchbase api if not with service'
    end
  end
end
