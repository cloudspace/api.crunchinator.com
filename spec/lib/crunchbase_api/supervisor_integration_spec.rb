require 'spec_helper'

describe "Worker system integration tests" do
  before(:each) do
  end

  it "should start workers and wait for them to finish"

  it "should run on a data set with data and populate the database", :threaded => true do
    ApiQueue::Queue.batch_enqueue('companies', ['rapleaf'], :local)
    ApiQueue::Source::Local.stub(:json_path).and_return(Rails.root.to_s + '/spec/fixtures')

    supervisor = ApiQueue::Supervisor.new(archive: [], process: true)
    supervisor.start_workers(1)

    # expect the element.complete to be true, element.error to be nil
    # not sure if this should go in this test

    # note that additional companies are created for acquisition data
    expect(Company.where(permalink: 'rapleaf', name: 'Rapleaf').count).to eq(1)
  end

  it "should run on an empty data set and return a success" do
    ApiQueue::Element.destroy_all
    supervisor = ApiQueue::Supervisor.new(archive: [])
    expect(supervisor.start_workers).to be_true
  end

  it "should automatically shutdown if there are 50 consecutive combined errors on the workers"

  it "queue elements should be updated on a success"

  it "queue elements should be updated on a failure"
end
