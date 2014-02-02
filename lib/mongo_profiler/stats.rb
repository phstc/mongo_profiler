module MongoProfiler
  class Stats
    def initialize(statsd_client)
      @statsd_client = statsd_client
    end

    def populate(_caller, total_time)
      file   = sanitaze_stat_key _caller.file.split('/').last
      method = sanitaze_stat_key _caller.method

      stat_name     = "mongo_profiler.#{MongoProfiler.application_name}.#{file}.#{method}"

      total_time_ms = total_time * 1000

      @statsd_client.increment stat_name
      @statsd_client.timing    stat_name, total_time_ms
    end

    private

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
