require 'spec_helper'

describe ApiQueue::Source::S3 do
  describe 'class methods' do
    describe 'fetch_entities' do
      it 'should return an array of permalinks when run' do
        obj = double
        obj.stub(:key) { 'companies/cloudspace.json' }
        payload = [obj]
        ApiQueue::Source::S3.stub_chain(:bucket, :objects, :with_prefix).and_return(payload)
        expect(ApiQueue::Source::S3.fetch_entities(:company)).to eq(['cloudspace'])
      end
    end

    describe 'fetch_entity' do
      it 'should return the json corresponding to a permalink' do
        obj = double
        obj.stub(:read) { 'entity json' }
        payload = { 'companies/cloudspace.json' => obj }
        ApiQueue::Source::S3.stub_chain(:bucket, :objects).and_return(payload)
        expect(ApiQueue::Source::S3.fetch_entity(:company, 'cloudspace')).to eq('entity json')
      end
    end

    describe 'save_entity' do
      it 'should call upload_file with the proper arguments' do
        ApiQueue::Source::S3.should_receive(:upload_file).with('crunchinator.com', 'companies/cloudspace.json', 'json')
        ApiQueue::Source::S3.save_entity(:company, 'cloudspace', 'json')
      end
    end

    describe 'upload_file' do
      it 'should attempt to write a file to S3' do
        receiver = double
        receiver.should_receive(:write).with('json data')
        ApiQueue::Source::S3.stub_chain(:bucket, :objects, :[]) { receiver }
        ApiQueue::Source::S3.upload_file(:companies, 'filename', 'json data')
      end
    end

    describe 'upload_and_expose' do
      it 'should attempt to write a file to S3' do
        ApiQueue::Source::S3.stub(:gzip) { 'gzipped json' }
        receiver = double
        receiver.should_receive(:write).with('gzipped json',
                                             acl: :public_read,
                                             content_type: 'json',
                                             content_encoding: 'gzip')
        ApiQueue::Source::S3.stub_chain(:bucket, :objects, :[]) { receiver }
        ApiQueue::Source::S3.upload_and_expose(:companies, 'filename', 'json data')
      end
    end

    describe 'empty_bucket!' do
      it 'should call the :clear! method on the bucket' do
        bucket = double(AWS::S3::Bucket)
        bucket.should_receive(:clear!)
        ApiQueue::Source::S3.stub(:bucket) { bucket }
        ApiQueue::Source::S3.empty_bucket!('crunchinator.com')
      end
    end

    describe 'bucket' do
      it 'should call service.buckets.[](<bucket name>)' do
        receiver = double
        receiver.should_receive(:[]).with('bucket name')
        service = double(AWS::S3)
        service.stub(:buckets) { receiver }
        ApiQueue::Source::S3.stub(:service) { service }
        ApiQueue::Source::S3.bucket('bucket name')
      end
    end

    describe 'service' do
      it 'should return an authorized AWS::S3 object' do
        expect(ApiQueue::Source::S3.service.class).to eq(AWS::S3)
      end
    end
  end
end
