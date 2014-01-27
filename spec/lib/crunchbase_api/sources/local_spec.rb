require 'spec_helper'

describe ApiQueue::Source::Local do
  describe 'class methods' do
    describe 'fetch_entities' do
      it 'should return an array of permalinks for any files exist in the json_data folder which end in .json' do
        Dir.stub(:exist?) { true }
        Dir.stub(:entries) { ['entity1.json', 'entity2.json', 'not an entity'] }
        expect(ApiQueue::Source::Local.fetch_entities(:company)).to eq(%w[entity1 entity2])
      end

      it 'should return an empty array if the json_data folder doesn\'t exist' do
        Dir.stub(:exist?) { false }
        expect(ApiQueue::Source::Local.fetch_entities(:company)).to eq([])
      end
    end

    describe 'fetch_entity' do
      it 'returns json on success' do
        File.should_receive(:open).with("#{Rails.root}/json_data/companies/foo.json")
        ApiQueue::Source::Local.fetch_entity(:company, 'foo')
      end
    end

    describe 'save_entity' do
      it 'should create the file' do
        FileUtils.stub(:mkpath)
        ApiQueue::Source::Local.should_receive(:open).with("#{Rails.root}/json_data/companies/cloudspace.json", 'wb')
        ApiQueue::Source::Local.save_entity(:company, 'cloudspace', 'sample json')
      end
    end
  end
end
