module MongoProfiler
  module WebHelpers
    def root_path
      "#{env['SCRIPT_NAME']}/"
    end

    def graphite_graph_url(profile, from, size)
      file   = sanitaze_stat_key(profile['file'].split('/').last)
      method = sanitaze_stat_key(profile['method'])

      "http://graphite.spree.fm/render?from=#{from}&until=now&width=400&height=250&target=alias(summarize(stats_counts.augury.staging.mongo_profiler.#{MongoProfiler.application_name}.#{file}.#{method}, '#{size}', 'sum'), '#{file}#{method}')&title=Last day/hour"
    end

    private

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
