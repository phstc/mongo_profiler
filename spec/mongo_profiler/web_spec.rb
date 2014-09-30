require 'spec_helper'
require 'mongo_profiler/web'
require 'rack/test'

module MongoProfiler
  describe Web do
    include Rack::Test::Methods

    def app
      described_class
    end
  end
end
