module MongoProfiler
  class Stats
    def initialize(stats_client)
      @stats_client = stats_client
    end

    def populate(_caller, total_time)
      file   = sanitaze_stat_key _caller.file.split('/').last
      method = sanitaze_stat_key _caller.method

      stat_name     = "mongo_profiler.#{MongoProfiler.application_name}.#{file}.#{method}"

      total_time_ms = total_time * 1000

      @stats_client.increment stat_name
      @stats_client.timing    stat_name, total_time_ms
    end

    private

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
