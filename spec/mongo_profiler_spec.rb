require 'spec_helper'

describe MongoProfiler do
  describe '.log' do
    it 'merges required keys' do
      expect(MongoProfiler.collection).to receive(:insert).with({ application_name: MongoProfiler.application_name, group_id: MongoProfiler.group_id})

      described_class.log({})
    end
  end

  describe '.connect' do
    context 'without any argument' do
      it 'connects to a mongo database' do
        expect {
          described_class.connect

          expect(described_class.connected?).to be_true
        }.to_not raise_error
      end
    end

    context 'with arguemtns' do
      it 'connects with host, port and database' do
        expect {
          described_class.connect('localhost', 27017, 'augury_development')

          expect(described_class.connected?).to be_true
        }.to_not raise_error
      end
    end

    context 'when invalid config' do
      it 'connects with host, port and database' do
        expect {
          described_class.connect('xxx')
        }.to raise_error

        expect(described_class.connected?).to be_false
      end
    end
  end

  describe '.should_skip?' do
    let(:_caller) {
      [
        "/Users/pablo/workspace/project/file.rb:7:in `new'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `fetch'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block in let'"
      ]
    }

    it 'accepts valid payload' do
      payload = { :database   => 'project',
                  :collection => 'stores',
                  :selector   => { '_id' => BSON::ObjectId('5282d125755b1c7f2c000005') },
                  :limit      => -1 }

      expect(described_class.should_skip?(payload, MongoProfiler::Caller.new(_caller))).to be_false
    end

    it 'skips $cmd for unknown collections' do
      payload = { :database   => 'project',
                  :collection => '$cmd',
                  :selector   => { :getnonce => 1 },
                  :limit      => -1 }

      expect(described_class.should_skip?(payload, MongoProfiler::Caller.new(_caller))).to be_true
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
      expect(described_class.group_id).to match /process_pid/
      expect(described_class.group_id).to match /thread_object_id/
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
