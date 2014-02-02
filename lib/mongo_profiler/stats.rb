module MongoProfiler
  class Stats
    def initialize(statsd_client)
      @statsd_client = statsd_client
    end

    def populate(_caller, time_spent)
      file   = sanitaze_stat_key _caller.file.split('/').last
      method = sanitaze_stat_key _caller.method

      stat_name     = "mongo_profiler.#{MongoProfiler.application_name}.#{file}.#{method}"

      time_spent_ms = time_spent * 1000

      @statsd_client.increment stat_name
      @statsd_client.timing    stat_name, time_spent_ms
    end

    private

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
