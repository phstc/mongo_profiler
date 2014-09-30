require 'spec_helper'
require 'mongo_profiler/web_helpers'

module MongoProfiler
  describe WebHelpers do
    subject { Class.new { include MongoProfiler::WebHelpers }.new }
  end
end
