require 'uri'

module MongoProfiler
  module WebHelpers
    def root_path
      "#{env['SCRIPT_NAME']}/"
    end

    def graphite_graph_url(profile, from, size, title)
      file             = profile['file']
      method           = profile['method']
      application_name = profile['application_name']

      URI.escape(["#{MongoProfiler.graphite_url}/render?",
                  "from=#{from}&",
                  'until=now&width=400&height=250&',
                  "target=#{graphite_target(application_name, file, method, size)}",
                  "&title=#{title}"].join)
    end

    private

    def graphite_target(application_name, file, method, size)
      file       = file.split('/').last
      file_key   = sanitaze_stat_key(file)
      method_key = sanitaze_stat_key(method)

      "alias(summarize(stats_counts.augury.staging.mongo_profiler.#{application_name}.#{file_key}.#{method_key}, '#{size}', 'sum'), '#{file}##{method}')"
    end

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
