require 'spec_helper'
require Rails.root.to_s + "/lib/trackable_tasks/crunchbase_seed_s3"

describe CrunchbaseSeedS3 do
  before :each do
    @task = CrunchbaseSeedS3.new
  end

  describe 'run' do
    it 'should create a folder called companies'
    it 'should initialize a new s3 bucket'
  end
end
