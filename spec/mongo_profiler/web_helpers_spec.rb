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
        it 'generates graphite url' do
          expect(subject.graphite_graph_url(profile, '-1h', '1min', 'hello')).to eq("http://graphite/render?from=-1h&until=now&width=400&height=250&target=alias(summarize(stats_counts.augury.staging.mongo_profiler..schedule_rb.load_schedulers,%20'1min',%20'sum'),%20'schedule.rb%23load_schedulers')&title=hello")
        end
      end
    end
  end
end
