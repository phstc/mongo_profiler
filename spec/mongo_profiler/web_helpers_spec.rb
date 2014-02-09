require 'spec_helper'
require 'mongo_profiler/web_helpers'

module MongoProfiler
  describe WebHelpers do
    subject { Class.new { include MongoProfiler::WebHelpers }.new }


    describe '#graphite_graph_url' do

      before { MongoProfiler.graphite_url = 'http://graphite' }

      let(:profile) { { 'method' => 'load_schedulers',
                        'file'   => '/workspace/project/config/schedule.rb',
                        'line'   => 11,
                        'method' => 'load_schedulers' } }

      context 'when -1h and 1min' do
        xit 'generates graphite url' do
          expect(subject.graphite_graph_url(profile, '-1h', '1min', 'hello')).to eq("http://graphite/render?from=-1h&until=now&width=400&height=250&target=alias(summarize(stats_counts.augury.staging.mongo_profiler..schedule_rb.load_schedulers,%20'1min',%20'sum'),%20'schedule.rb%23load_schedulers')&title=hello")
        end
      end
    end

    describe '#print_backtrace_entry' do
      it 'prints project entry' do
        c = %{/Users/pablo/workspace/augury_admin/app/controllers/queues_controller.rb:34:in `show'}
        expect(subject.print_backtrace_entry(c)).to eq %{<span class="btn-info">#{c}</span>}
      end

      context 'when gem/ruby' do
        it 'prints dependency entry' do
          c = %{/Users/pablo/.gem/ruby/2.0.0/gems/rack-1.4.5/lib/rack/session/abstract/id.rb:210:in `context'}
          expect(subject.print_backtrace_entry(c)).to eq c
        end
      end

      context 'when rubies/ruby' do
        it 'prints dependency entry' do
          c = %{/Users/pablo/.rubies/ruby-2.0.0-p247/lib/ruby/2.0.0/webrick/httpserver.rb:94:in `run'}
          expect(subject.print_backtrace_entry(c)).to eq c
        end
      end

      context 'when bundle/ruby' do
        it 'prints dependency entry' do
          c = %{/Users/pablo/bundle/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'}
          expect(subject.print_backtrace_entry(c)).to eq c
        end
      end
    end
  end
end
