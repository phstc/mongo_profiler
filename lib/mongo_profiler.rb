require 'json'
require 'mongoid'
require 'active_support/core_ext/hash/indifferent_access'

require 'mongo_profiler/version'
require 'mongo_profiler/caller'
require 'mongo_profiler/util'
require 'mongo_profiler/extensions/moped'
require 'mongo_profiler/models/profile'
require 'mongo_profiler/models/profile_group'

module MongoProfiler
  class << self
    def current_group_name=(group_name)
      Thread.current['mongo_profiler_group_name'] = group_name
    end

    def current_group_name
      Thread.current['mongo_profiler_group_name'] || 'Undefined group name'
    end
  end
end
