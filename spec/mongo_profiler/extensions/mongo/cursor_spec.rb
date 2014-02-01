require 'spec_helper'

describe 'Mongo::Cursor' do
  describe '#send_initial_query' do
    let(:profiler) { MongoProfiler::Profiler.new(DB) }

    it 'creates a profiler entry' do
      profiler.enable!

      expect {
        COLL.insert(test: 'test')
        expect(COLL.find_one['test']).to eq 'test'
      }.to change { profiler.collection.count }.by(1)
    end

    it 'skips profiler entry' do
      profiler.disable!

      expect {
        COLL.insert(test: 'test')
        expect(COLL.find_one['test']).to eq 'test'
      }.to_not change { profiler.collection.count }
    end
  end
end
