require 'json'
require 'mongoid'
require 'active_support/core_ext/hash/indifferent_access'

require 'mongo_profiler/version'
require 'mongo_profiler/caller'
require 'mongo_profiler/extensions/moped'
require 'mongo_profiler/models/profile'
require 'mongo_profiler/models/profile_group'

module MongoProfiler
  class << self
  end
end
