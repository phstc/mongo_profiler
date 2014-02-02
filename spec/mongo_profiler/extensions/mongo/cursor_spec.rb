require 'spec_helper'

describe 'Mongo::Cursor' do
  describe '#send_initial_query' do
    let(:profiler) { MongoProfiler::Profiler.new(DB) }

    context 'when enabled' do
      let(:statsd_client) { double('StatsD client').as_null_object }

      before do
        profiler.enable!

        MongoProfiler.statsd_client = statsd_client
      end

      it 'populate stats' do
        expect(statsd_client).to receive(:increment).with(any_args)
        expect(statsd_client).to receive(:timing).with(any_args)

        COLL.find_one
      end

      it 'creates a profiler entry' do
        expect {
          COLL.insert(test: 'test')
          expect(COLL.find_one['test']).to eq 'test'
        }.to change { profiler.collection.count }.by(1)
      end
    end

    context 'when disabled' do
      before { profiler.disable! }

      it 'skips profiler entry' do
        expect {
          COLL.insert(test: 'test')
          expect(COLL.find_one['test']).to eq 'test'
        }.to_not change { profiler.collection.count }
      end
    end
  end
end
