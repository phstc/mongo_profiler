Mongo::Cursor.class_eval do
  alias_method :original_send_initial_query, :send_initial_query

  def send_initial_query
    beginning_time = Time.now
    original_send_initial_query
    time_spent = Time.now - beginning_time
    begin
      profiler = MongoProfiler::Profiler.new(@db)

      return if profiler.should_skip?(instrument_payload) || profiler.disabled?

      result = {}

      result[:time_spent] = time_spent

      # the payload sent to mongo
      result[:instrument_payload] = JSON.dump(instrument_payload)

      _caller = MongoProfiler::Caller.new(caller)

      result[:file]   = _caller.file
      result[:line]   = _caller.line
      result[:method] = _caller.method

      result[:extra_attrs] = MongoProfiler.extra_attrs

      # TODO rename `_caller` object instance to something more meaningful in this context
      result[:backtrace]  = _caller._caller

      profiler.log(result)
      # MongoProfiler.populate_stats(_caller, time_spent)
    rescue => e
      binding.pry
      p "MongoProfiler: #{e.message}"
    end
  end
end
