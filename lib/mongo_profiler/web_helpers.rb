require 'uri'

module MongoProfiler
  module WebHelpers
    def root_path
      "#{env['SCRIPT_NAME']}/"
    end

    def graphite_graph_timers_url(profile, from, size, title)
      file             = profile['file']
      method           = profile['method']
      application_name = profile['application_name']

      URI.escape(["#{MongoProfiler.graphite_url}/render?",
                  "from=#{from}&",
                  'until=now&width=400&height=250&',
                  "target=#{graphite_timers_target(application_name, file, method, size)}",
                  "&title=#{title}"].join)
    end

    def graphite_graph_count_url(profile, from, size, title)
      file             = profile['file']
      method           = profile['method']
      application_name = profile['application_name']

      URI.escape(["#{MongoProfiler.graphite_url}/render?",
                  "from=#{from}&",
                  'until=now&width=400&height=250&',
                  "target=#{graphite_count_target(application_name, file, method, size)}",
                  "&title=#{title}"].join)
    end

    def print_backtrace_entry(entry)
      if entry.include?('gem/ruby') || entry.include?('rubies/ruby') || entry.include?('bundle/ruby')
        entry
      else
        %{<span class="btn-info">#{entry}</span>}
      end
    end

    private

    def graphite_timers_target(application_name, file, method, size)
      file       = file.split('/').last
      file_key   = sanitaze_stat_key(file)
      method_key = sanitaze_stat_key(method)

      "alias(summarize(stats.timers.#{MongoProfiler.stats_prefix}mongo_profiler.#{application_name}.#{file_key}.#{method_key}.mean, '#{size}', 'mean'), '#{file}##{method}')"
    end

    def graphite_count_target(application_name, file, method, size)
      file       = file.split('/').last
      file_key   = sanitaze_stat_key(file)
      method_key = sanitaze_stat_key(method)

      binding.pry

      "alias(summarize(stats_counts.#{MongoProfiler.stats_prefix}mongo_profiler.#{application_name}.#{file_key}.#{method_key}, '#{size}', 'sum'), '#{file}##{method}')"
    end

    def sanitaze_stat_key(key)
      key.gsub(/\W/, '_')
    end
  end
end
