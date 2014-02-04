require 'spec_helper'

describe MongoProfiler do
  describe '#log' do
    it 'merges required keys' do
      expect(MongoProfiler.collection).to receive(:insert).with({ application_name: MongoProfiler.application_name, group_id: MongoProfiler.group_id})

      described_class.log({})
    end
  end

  describe '#should_skip?' do
    it 'accepts valid payload' do
      payload = { :database   => 'project',
                  :collection => 'stores',
                  :selector   => { '_id' => BSON::ObjectId('5282d125755b1c7f2c000005') },
                  :limit      => -1 }

      expect(described_class.should_skip?(payload)).to be_false
    end

    it 'skips $cmd for unknown collections' do
      payload = { :database   => 'project',
                  :collection => '$cmd',
                  :selector   => { :getnonce => 1 },
                  :limit      => -1 }

      expect(described_class.should_skip?(payload)).to be_true
    end
  end

  describe '.extra_attrs' do
    it 'sets an extra attr' do
      described_class.extra_attrs['test'] = 'test_value'

      expect(described_class.extra_attrs['test']).to eq 'test_value'
    end
  end

  describe '.group_id' do
    it 'uses default keys by default' do
      expect(described_class.group_id).to have_key(:process_pid)
      expect(described_class.group_id).to have_key(:thread_object_id)
    end
  end

  describe 'enabled and disable' do
    context 'when disabled' do
      before { described_class.disable! }

      it(:disabled?) { be_true }
      it(:enabled?)  { be_false }
    end

    context 'when enabled' do
      before { described_class.enable! }

      it(:enabled?)  { be_true }
      it(:disabled?) { be_true }
    end
  end

  describe '#collection' do
    it { expect(described_class.collection).to be_a(Mongo::Collection) }
    it { expect(described_class.collection.name).to eq 'mongo_profiler' }
  end

  describe '#collection_config' do
    it { expect(described_class.collection_config).to be_a(Mongo::Collection) }
    it { expect(described_class.collection_config.name).to eq 'mongo_profiler_config' }
  end
end
