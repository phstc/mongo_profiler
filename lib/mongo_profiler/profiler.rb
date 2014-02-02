module MongoProfiler
  class Profiler
    def initialize(db)
      @db = db
    end

    def log(document)
      collection.insert(document.merge(application_name: MongoProfiler.application_name, group_id: MongoProfiler.group_id))
    end

    def should_skip?(payload)
      return true unless payload

      payload = payload.to_h.dup.with_indifferent_access

      if !payload['database'].to_s.match(/^admin|system/).nil? ||
        !payload['collection'].to_s.match(/^mongo_|system/).nil? ||
        !payload['selector'].to_h['count'].to_s.match(/^mongo_|system/).nil? ||
        !payload['selector'].to_h['distinct'].to_s.match(/^mongo_|system/).nil?

        return true
      end

      if payload['collection'] == '$cmd'
        # check acceptable commands - must be count or distinct
        return !(payload['selector'].to_h.has_key?('count') || payload['selector'].to_h.has_key?('distinct'))
      end

      false
    end

    def create_collections
      # http://docs.mongodb.org/manual/core/capped-collections/
      # Config database must have only one document
      # 1_048_576 - 1MB
      # db.mongo_profiler_config.drop()
      # db.createCollection('mongo_profiler_config', { capped: true, size: 1048576, max: 1 })
      @db.create_collection(COLLECTION_CONFIG_NAME, { capped: true, size: 1_048_576, max: 1 })

      @db.create_collection(COLLECTION_PROFILER_NAME, { capped: true, size: 4_001_792, max: 9223372036854775807 })
      # 4_001_792   - 3.82MB - db.system.profile.stats()
      # 104_857_600 - 100MB
      # db.mongo_profiler.drop()
      # db.createCollection('mongo_profiler', { capped: true, size: 4001792, max: 9223372036854775807 })
    end

    def collection
      @collection ||= @db[COLLECTION_PROFILER_NAME]
    end

    def collection_config
      @collection_config ||= @db[COLLECTION_CONFIG_NAME]
    end

    def disable!
      collection_config.insert({ enabled: false })
    end

    def enable!
      collection_config.insert({ enabled: true })
    end

    def enabled?
      !!collection_config.find.first.to_h['enabled']
    end

    def disabled?
      !enabled?
    end
  end
end
