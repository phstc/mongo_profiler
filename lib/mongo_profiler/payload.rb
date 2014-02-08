module MongoProfiler
  class Payload
    attr_reader :payload

    def initialize(payload)
      @payload = (payload || {}).dup.with_indifferent_access
    end

    def system_database?
      !payload['database'].to_s.match(/^admin|system/).nil?
    end

    def system_collection?
      !payload['collection'].to_s.match(/^mongo_|system/).nil?
    end

    def system_count?
      !payload['selector'].to_h['count'].to_s.match(/^mongo_|system/).nil?
    end

    def system_distinct?
      !payload['selector'].to_h['distinct'].to_s.match(/^mongo_|system/).nil?
    end

    def system_command?
      # check acceptable commands - must be count or distinct
      payload['collection'] == '$cmd' && (!payload['selector'].to_h.has_key?('count') ||
                                          payload['selector'].to_h.has_key?('distinct'))
    end

    def system_any?
      system_database? ||
        system_collection? ||
        system_count? ||
        system_distinct? ||
        system_command?
    end
  end
end
