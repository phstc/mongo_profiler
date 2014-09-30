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

    belongs_to :profile_group

    class << self
      def register(started_at, database, collection, selector, options = {})
        return if collection =~ /mongo_profiler/

        _caller = MongoProfiler::Caller.new(caller)


        # TODO Move group creation to ProfileGroup
        group_name = Thread.current['mongo_profiler_group_name'] || 'Undefined group name'
        group_id = Digest::MD5.hexdigest(group_name)

        group = ProfileGroup.find_or_create_by(id: group_name, name: group_name)

        group.touch

        query = if selector.has_key?('$query')
                  selector['$query']
                else
                  selector
                end

        # TODO implement deep_keys
        id = collection + query.keys.sort.join + _caller.file + _caller.line.to_s
        id = Digest::MD5.hexdigest(id)

        result = {}
        result[:total_time]         = elapsed(started_at)
        result[:command_database]   = database
        result[:command_collection] = collection
        result[:command]            = JSON.dump(query)
        result[:file]               = _caller.file
        result[:line]               = _caller.line
        result[:method]             = _caller.method
        result[:profile_group]      = group

        result[:id] = id

        # TODO do it in background
        result[:explain] = JSON.dump(self.collection.find(query).explain)

        self.create(result)
      end

      private

      def elapsed(started_at)
        (Time.now - started_at) * 1000
      end
    end
  end
end
