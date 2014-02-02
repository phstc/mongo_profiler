require 'spec_helper'

module MongoProfiler
  describe Profiler do
    subject { Profiler.new(DB) }

    before { MongoProfiler.application_name = 'project' }

    describe '#log' do
      it 'merges required keys' do
        expect(subject.collection).to receive(:insert).with({ application_name: MongoProfiler.application_name, group_id: MongoProfiler.group_id})

        subject.log({})
      end
    end

    describe '#should_skip?' do
      it 'accepts valid payload' do
        payload = { :database   => 'project',
                    :collection => 'stores',
                    :selector   => { '_id' => BSON::ObjectId('5282d125755b1c7f2c000005') },
                    :limit      => -1 }

        expect(subject.should_skip?(payload)).to be_false
      end

      it 'skips $cmd for unknown collections' do
        payload = { :database   => 'project',
                    :collection => '$cmd',
                    :selector   => { :getnonce => 1 },
                    :limit      => -1 }

        expect(subject.should_skip?(payload)).to be_true
      end
    end

    describe 'enabled and disable' do
      context 'when disabled' do
        before { subject.disable! }

        it(:disabled?) { be_true }
        it(:enabled?)  { be_false }
      end

      context 'when enabled' do
        before { subject.enable! }

        it(:enabled?)  { be_true }
        it(:disabled?) { be_true }
      end
    end

    describe '#collection' do
      it { expect(subject.collection).to be_a(Mongo::Collection) }
      it { expect(subject.collection.name).to eq 'mongo_profiler' }
    end

    describe '#collection_config' do
      it { expect(subject.collection_config).to be_a(Mongo::Collection) }
      it { expect(subject.collection_config.name).to eq 'mongo_profiler_config' }
    end
  end
end
