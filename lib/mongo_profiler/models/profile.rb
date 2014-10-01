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
    field :selector_md5, type: String

    belongs_to :profile_group

    index group_id: 1, selector_md5: 1

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
    rescue => e
      e.message
    end

    class << self
      def register(started_at, database, collection, selector, options = {})
        return if collection =~ /mongo_profiler/
        return if selector['$explain']

        _caller = MongoProfiler::Caller.new(caller)

        # TODO Move group creation to ProfileGroup
        group_name = MongoProfiler.current_group_name
        group_id = Digest::MD5.hexdigest(group_name)

        group = ProfileGroup.find_or_create_by(id: group_id, name: group_name)

        group.touch

        query = if selector.has_key?('$query')
                  selector['$query']
                else
                  selector
                end

        # TODO implement deep_keys
        selector_md5_s = collection + query.keys.sort.join + _caller.file + _caller.line.to_s
        selector_md5 = Digest::MD5.hexdigest(selector_md5_s)

        return if Profile.where(selector_md5: selector_md5, profile_group_id: group_id).any?

        result = {}
        result[:selector_md5]       = selector_md5
        result[:profile_group_id]   = group_id

        result[:total_time]         = elapsed(started_at)
        result[:command_database]   = database
        result[:command_collection] = collection
        result[:command]            = JSON.dump(query)
        result[:file]               = _caller.file
        result[:line]               = _caller.line
        result[:method]             = _caller.method

        # TODO do it in background
        result[:explain] = JSON.dump(self.collection.database[collection].find(query).explain)

        self.create(result)
      end

      private

      def elapsed(started_at)
        (Time.now - started_at) * 1000
      end
    end
  end
end
