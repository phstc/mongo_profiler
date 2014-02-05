require 'spec_helper'
require 'mongo_profiler/web'
require 'rack/test'

module MongoProfiler
  describe Web do
    include Rack::Test::Methods

    def app
      described_class
    end

    describe 'POST /profiler/enable' do
      it 'enables profiler' do
        MongoProfiler.disable!

        post '/profiler/enable'

        expect(last_response.status).to eq 302
        expect(MongoProfiler.enabled?).to be_true
      end
    end

    describe 'POST /profiler/disable' do
      it 'disables profiler' do
        MongoProfiler.enable!

        post '/profiler/disable'

        expect(last_response.status).to eq 302
        expect(MongoProfiler.disabled?).to be_true
      end
    end

    describe 'GET /settings' do
      it 'returns stats' do
        get '/settings'

        expect(last_response.body).to match /mongo_profiler/
        expect(last_response.body).to match /mongo_profiler_config/
      end
    end

    describe 'GET /profiler/groups/:group_id' do
      pending
    end

    describe 'GET /profiler/:_id/explain' do
      pending
    end
  end
end
