require 'mongo'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

require 'mongo_profiler/version'
require 'mongo_profiler/profiler'
require "mongo_profiler/caller"
require "mongo_profiler/stats"
require "mongo_profiler/extensions/mongo/cursor"

module MongoProfiler
  COLLECTION_CONFIG_NAME   = 'mongo_profiler_config'
  COLLECTION_PROFILER_NAME = 'mongo_profiler'

  class << self
    attr_accessor :extra_attrs, :group_id, :application_name, :statsd_client

    def extra_attrs
      @extra_attrs ||= {}
    end

    def group_id
      # The group_id is used to determine the life cycle where the queries ocurred.
      # For web applications a life cycle can be a request.
      # So people can filter all Mongo Queries per request based on request#url and/or request#uuid.
      @group_id ||= { process_pid:       Process.pid,
                      thread_object_id:  Thread.current.object_id }
    end

    def statsd_client=(statsd_client)
      @statsd_client = MongoProfiler::Stats.new(statsd_client)
    end
  end
end
