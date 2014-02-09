require 'mongo'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

require 'mongo_profiler/version'
require 'mongo_profiler/profiler'
require 'mongo_profiler/caller'
require 'mongo_profiler/payload'
require 'mongo_profiler/stats'

module MongoProfiler
  COLLECTION_CONFIG_NAME   = 'mongo_profiler_config'
  COLLECTION_PROFILER_NAME = 'mongo_profiler'

  class << self
    attr_accessor :extra_attrs,
      :group_id,
      :application_name,
      :stats_client,
      :stats_prefix,
      :graphite_url

    attr_reader :database

    def log(document)
      collection.insert(document.merge(application_name:  MongoProfiler.application_name,
                                       group_id:          MongoProfiler.group_id))
    end

    def should_skip?(payload, _caller)
      Payload.new(payload).system_any? || _caller.mongo_profiler_caller?
    end

    def disable!
      collection_config.insert(enabled: false)
    end

    def enable!
      collection_config.insert(enabled: true)
    end

    def enabled?
      !!collection_config.find.first.to_h['enabled']
    end

    def disabled?
      !enabled?
    end

    def extra_attrs
      @extra_attrs ||= {}
    end

    def group_id
      # The group_id is used to determine the life cycle where the queries ocurred.
      # For web applications a life cycle can be a request.
      # So people can filter all Mongo Queries per request based on request#url and/or request#uuid.
      @group_id ||= { process_pid:       Process.pid,
                      thread_object_id:  Thread.current.object_id }.to_a.join('-')
    end

    def stats_client=(stats_client)
      @stats_client = MongoProfiler::Stats.new(stats_client)
    end

    def create_collections
      # http://docs.mongodb.org/manual/core/capped-collections/
      # Config database must have only one document
      # 1_048_576 - 1MB
      # db.mongo_profiler_config.drop()
      # db.createCollection('mongo_profiler_config', { capped: true, size: 1048576, max: 1 })
      @database.create_collection(COLLECTION_CONFIG_NAME, capped: true, size: 1_048_576, max: 1)

      @database.create_collection(COLLECTION_PROFILER_NAME, capped: true, size: 4_001_792, max: 9223372036854775807)
      # 4_001_792   - 3.82MB - db.system.profile.stats()
      # 104_857_600 - 100MB
      # db.mongo_profiler.drop()
      # db.createCollection('mongo_profiler', { capped: true, size: 4001792, max: 9223372036854775807 })
    end

    def collection
      @collection ||= @database[COLLECTION_PROFILER_NAME]
    end

    def collection_config
      @collection_config ||= @database[COLLECTION_CONFIG_NAME]
    end

    def connected?
      !!(@connection && @database)
    end

    def connect(host = 'localhost', port = 27017, db = nil, user = nil, pass = nil, options = {})
      @connection, @database = nil

      @connection = Mongo::MongoClient.new(host, port, options)
      if db
        @database = @connection.db(db)
      else
        # default database
        @database = @connection.db
      end
      @database.authenticate(user, pass) if user && pass
    end
  end
end
