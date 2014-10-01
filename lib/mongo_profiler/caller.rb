module MongoProfiler
  class Caller
    attr_reader :file, :line, :method, :_caller

    def initialize(_caller)
      @_caller = _caller

      caller_head = project_callers[0].split ':'

      # i.e. "/Users/pablo/workspace/project/spec/mongo_profiler_spec.rb:7:in `new'",
      @file   = caller_head[0]
      @line   = caller_head[1].to_i
      @method = project_callers[0][/`.*'/][1..-2]
    end

    private

    def project_callers
      # skip gem/bundle entries
      @project_callers ||= _caller.reject do |entry|
        entry.include?('bundle/ruby') || entry.include?('gem/ruby') || entry.include?('rubies/ruby') || entry.include?('extensions/moped.rb')
      end
    end
  end
end
