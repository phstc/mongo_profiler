require 'spec_helper'

module MongoProfiler
  describe Profiler do
    subject { Profiler.new(DB) }

    describe '.extra_attr=' do
      xit 'set an extra attr' do
        described_class.extra_attrs['test'] = 'test_value'

        expect(described_class.extra_attrs['test']).to eq 'test_value'
      end
    end

    describe '.group_id' do
      xit 'uses default_attrs keys by default' do
        expect(described_class.group_id).to eq described_class.default_attrs.values.join('-')
      end
    end

    describe '.log' do
      it 'persist group_id'
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

    describe '.populate_stats' do
      let(:caller_obj) { MongoProfiler::Caller.new(_caller) }
      let(:_caller) {
        [
          "/Users/pablo/workspace/project/spec/mongo_profiler_spec.rb:7:in `new'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `fetch'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block in let'"
        ]
      }

      xit 'populates increment and timing' do
        stat_client = double 'Stats Client'

        expect(stat_client).to receive(:increment).with('mongo_profiler.project.mongo_profiler_spec_rb.new')
        expect(stat_client).to receive(:timing).with('mongo_profiler.project.mongo_profiler_spec_rb.new', 5000)

        described_class.populate_stats(caller_obj, 5, stat_client)
      end
    end
  end
end
