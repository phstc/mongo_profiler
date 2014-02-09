require 'spec_helper'

describe 'Mongo::Cursor' do
  let(:collection) { COLL }

  describe '#send_initial_query' do
    context 'when enabled' do
      let(:stats_client) { double('StatsD client').as_null_object }

      before do
        MongoProfiler.enable!

        MongoProfiler.stats_client = stats_client
      end

      it 'populate stats' do
        expect(stats_client).to receive(:increment).with(any_args)
        expect(stats_client).to receive(:timing).with(any_args)

        collection.find_one
      end

      it 'creates a profiler entry' do
        expect {
          collection.insert(test: 'test')
          expect(collection.find_one['test']).to eq 'test'
        }.to change { MongoProfiler.collection.count }.by(1)
      end
    end

    context 'when disabled' do
      before { MongoProfiler.disable! }

      it 'skips profiler entry' do
        expect {
          collection.insert(test: 'test')
          expect(collection.find_one['test']).to eq 'test'
        }.to_not change { MongoProfiler.collection.count }
      end
    end
  end
end
