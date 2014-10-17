require 'digest'

module MongoProfiler
  class Profile
    include Mongoid::Document
    include Mongoid::Timestamps

    field :total_time, type: Float
    field :command_database, type: String
    field :command_collection, type: String
    field :command, type: String
    field :explain, type: String
    field :file, type: String
    field :line, type: Integer
    field :method, type: String
    field :profile_md5, type: String

    belongs_to :profile_group

    index profile_group_id: 1, profile_md5: 1

    def score
      explain = JSON.parse(self.explain)

      n              = explain['n']
      ns_scanned     = explain['nscanned']
      cursor         = explain['cursor']
      scan_and_order = explain['scanAndOrder']

      case
      when cursor == 'BasicCursor'
        :no_index
      when n == 0
        :no_docs_found
      when ns_scanned == n
        :perfect
      when ns_scanned > n
        :scanned_more_than_returned
      when scan_and_order
        :had_to_order
      end
    end

    def file_reference
      "#{file.split('/').last}:#{line}"
    end

    def full_file_reference
      "#{file}:#{line}"
    end

    def command_order_by_keys
      selector = JSON.parse(command)

      selector['$orderby'].to_a.map do |k, v|

        if v == 1
          "#{k}.asc"
        else
          "#{k}.desc"
        end
      end
    end

    def command_query_keys
      selector = JSON.parse(command)
      hash = selector.include?('$query') ? selector['$query'] : selector

      MongoProfiler::Util.deep_keys(hash).reject { |k| k.starts_with? '$' }.uniq.to_a
    end

    class << self
      def register(started_at, database, collection, selector, options = {})
        return if collection =~ /mongo_profiler/ || collection =~ /system/
        return if selector['$explain']

        total_time = elapsed(started_at)

        _caller = MongoProfiler::Caller.new(caller)

        group = ProfileGroup.find_or_create_by(name: MongoProfiler.current_group_name)

        group.touch

        profile_md5 = generate_profile_md5(database, collection, selector, _caller)

        return if Profile.where(profile_group_id: group.id, profile_md5: profile_md5).any?

        result = {}
        result[:profile_md5]        = profile_md5
        result[:profile_group_id]   = group.id

        result[:total_time]         = total_time
        result[:command_database]   = database
        result[:command_collection] = collection
        result[:command]            = JSON.dump(selector)
        result[:file]               = _caller.file
        result[:line]               = _caller.line
        result[:method]             = _caller.method

        # TODO do it in background
        result[:explain] = JSON.dump(generate_explain(collection, selector))

        self.create(result)
      end

      def command_collection_names
        map = %Q{
          function() {
            emit(this.command_collection, 1);
          }
        }

        reduce = %Q{
          function(key, values) {
            var result = 0;
            values.forEach(function(value) {
              result += value;
            });
            return result;
          }
        }

        names = map_reduce(map, reduce).out(inline: true)
        names.sort_by do |n|
          n['_id']
        end
      end

      private

      def generate_explain(collection, selector)
        # https://jira.mongodb.org/browse/SERVER-14091
        s = if selector.has_key? '$query'
              selector
            else
              { '$query' => selector }
            end.merge('$explain' => true)

        self.collection.database[collection].find(s).first
      end

      def generate_profile_md5(database, collection, selector, _caller)
        profile_key = [
          database,
          collection,
          MongoProfiler::Util.deep_keys(selector).join,
          _caller.file,
          _caller.line.to_s
        ].join

        Digest::MD5.hexdigest(profile_key)
      end

      def elapsed(started_at)
        (Time.now - started_at) * 1000
      end
    end
  end
end
