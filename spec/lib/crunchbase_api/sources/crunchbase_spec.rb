require 'spec_helper'

describe ApiQueue::Source::Crunchbase do
  describe 'class methods' do
    describe 'fetch_entities' do
      before(:each) do
        @response = double(HTTParty::Response)
        @response.stub(:body).and_return("[{\"permalink\": \"permalink1\"}, {\"permalink\": \"permalink2\"}]")
        HTTParty.stub(:get).and_return(@response)
      end

      it 'should return an array of permalinks when run' do
        expect(ApiQueue::Source::Crunchbase.fetch_entities(:companies)).to eq(%w[permalink1 permalink2])
      end

      it 'should call the crunchbase API companies endpoint' do
        ApiQueue::Source::Crunchbase.stub(:api_key).and_return('foo')
        HTTParty.should_receive(:get).with('http://api.crunchbase.com/v/1/companies.js?api_key=foo')
        ApiQueue::Source::Crunchbase.fetch_entities(:companies)
      end
    end

    describe 'fetch_entity' do
      before(:each) do
        @response = double(HTTParty::Response)
        @response.stub(:body).and_return('foo')
        @response.stub(:code).and_return(200)
        HTTParty.stub(:get).and_return(@response)
      end

      it 'returns json on success' do
        expect(ApiQueue::Source::Crunchbase.fetch_entity(:company, 'google')).to eq('foo')
      end

      it 'retries if it is rate limited' do
        ApiQueue::Source::Crunchbase.stub(:rate_limited?) do
          ApiQueue::Source::Crunchbase.stub(:rate_limited?) { false }
          true
        end
        ApiQueue::Source::Crunchbase.should_receive(:sleep).once
        ApiQueue::Source::Crunchbase.fetch_entity(:company, 'google')
      end

      it 'calls handle_failure if the response code is not 200' do
        @response.stub(:code).and_return(500)
        HTTParty.stub(:get).and_return(@response)
        ApiQueue::Source::Crunchbase.should_receive(:handle_failure)
        ApiQueue::Source::Crunchbase.fetch_entity(:company, 'google')
      end
    end

    describe 'entity_uri' do
      it 'properly formats the uri' do
        ApiQueue::Source::Crunchbase.stub(:api_key).and_return('foo')
        expected_result = 'http://api.crunchbase.com/v/1/company/google.js?api_key=foo'
        expect(ApiQueue::Source::Crunchbase.send(:entity_uri, :company, 'google')).to eq(expected_result)
      end
    end

    describe 'rate_limited?' do
      before(:each) do
        @response = double(HTTParty::Response)
        @response.stub(:body).and_return('<h1>Developer Over Qps</h1>')
        @response.stub(:code).and_return(403)
      end

      it 'returns true if the user has been rate limited' do
        expect(ApiQueue::Source::Crunchbase.send(:rate_limited?, @response)).to eq(true)
      end

      it 'returns false for all other types of 403 errors' do
        @response.stub(:body).and_return('sample body text')
        expect(ApiQueue::Source::Crunchbase.send(:rate_limited?, @response)).to eq(false)
      end

      it 'returns false if the status code is not a 403' do
        @response.stub(:code).and_return(404)
        expect(ApiQueue::Source::Crunchbase.send(:rate_limited?, @response)).to eq(false)
      end
    end

    describe 'handle_failure' do
      it 'should raise an exception with a meaningful message' do
        response = double(HTTParty::Response)
        response.stub_chain(:response, :class).and_return('CLASS')
        response.stub(:code).and_return('CODE')
        response.stub(:message).and_return('MESSAGE')
        expect { ApiQueue::Source::Crunchbase.send(:handle_failure, response) }.to raise_error('CLASS CODE MESSAGE')
      end
    end

    describe 'api_key' do
      it 'should return a string representing the crunchbase API key' do
        old_key = ENV['CRUNCHBASE_API_KEY']
        ENV['CRUNCHBASE_API_KEY'] = 'the key'
        expect(ApiQueue::Source::Crunchbase.send(:api_key)).to eq('the key')
        ENV['CRUNCHBASE_API_KEY'] = old_key
      end
    end
  end
end
