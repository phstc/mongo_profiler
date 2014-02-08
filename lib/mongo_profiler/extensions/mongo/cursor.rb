Mongo::Cursor.class_eval do
  alias_method :original_send_initial_query, :send_initial_query

  def send_initial_query
    beginning_time = Time.now
    original_send_initial_query
    total_time = Time.now - beginning_time
    begin
      _caller = MongoProfiler::Caller.new(caller)

      return if MongoProfiler.should_skip?(instrument_payload, _caller) || MongoProfiler.disabled?

      result = {}

      result[:total_time] = total_time

      # the payload sent to mongo
      result[:instrument_payload] = JSON.dump(instrument_payload)

      result[:file]   = _caller.file
      result[:line]   = _caller.line
      result[:method] = _caller.method

      result[:extra_attrs] = MongoProfiler.extra_attrs

      # TODO rename `_caller` object instance to something more meaningful in this context
      result[:backtrace]  = _caller._caller

      MongoProfiler.log(result)

      if stats_client = MongoProfiler.stats_client
        stats_client.populate(_caller, total_time)
      end
    rescue => e
      p "MongoProfiler: #{e.message}"
    end
  end
end
