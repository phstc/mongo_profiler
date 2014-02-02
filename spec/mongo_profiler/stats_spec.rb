require 'spec_helper'

module MongoProfiler
  describe Stats do
    let(:statsd_client) { double 'StatsD Client' }
    subject { Stats.new(statsd_client) }

    before { MongoProfiler.application_name = 'project' }

    describe '#populate' do
      let(:_caller)    { MongoProfiler::Caller.new(backtrace) }
      let(:backtrace)  {
        [
          "/Users/pablo/workspace/project/spec/mongo_ruby_profiler_spec.rb:7:in `new'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `fetch'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block in let'"
        ]
      }

      it 'populates increment and timing' do
        expect(statsd_client).to receive(:increment).with('mongo_profiler.project.mongo_ruby_profiler_spec_rb.new')
        expect(statsd_client).to receive(:timing).with('mongo_profiler.project.mongo_ruby_profiler_spec_rb.new', 5000)

        subject.populate(_caller, 5)
      end
    end
  end
end
