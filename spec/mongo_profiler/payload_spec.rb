require 'spec_helper'

module MongoProfiler
  describe Payload do
    subject { described_class.new(payload) }

    describe '#system_database?' do
      context 'when admin' do
        let(:payload) { { database: 'admin' } }

        its(:system_database?) { should be_true }
      end

      context 'when system' do
        let(:payload) { { database: 'system' } }

        its(:system_database?) { should be_true }
      end

      context 'when other' do
        let(:payload) { { database: 'other' } }

        its(:system_database?) { should be_false }
      end
    end

    describe '#system_collection?' do
      context 'when admin' do
        let(:payload) { { collection: 'mongo_profiler' } }

        its(:system_collection?) { should be_true }
      end

      context 'when system' do
        let(:payload) { { collection: 'system' } }

        its(:system_collection?) { should be_true }
      end

      context 'when other' do
        let(:payload) { { collection: 'other' } }

        its(:system_collection?) { should be_false }
      end
    end

    describe '#system_count?' do
      context 'when admin' do
        let(:payload) { { selector: { count: 'mongo_profiler' } } }

        its(:system_count?) { should be_true }
      end

      context 'when system' do
        let(:payload) { { selector: { count: 'system' } } }

        its(:system_count?) { should be_true }
      end

      context 'when other' do
        let(:payload) { { selector: { count: 'other' } } }

        its(:system_count?) { should be_false }
      end
    end

    describe '#system_distinct?' do
      context 'when admin' do
        let(:payload) { { selector: { distinct: 'mongo_profiler' } } }

        its(:system_distinct?) { should be_true }
      end

      context 'when system' do
        let(:payload) { { selector: { distinct: 'system' } } }

        its(:system_distinct?) { should be_true }
      end

      context 'when other' do
        let(:payload) { { selector: { distinct: 'other' } } }

        its(:system_distinct?) { should be_false }
      end
    end

    describe '#system_command?' do
      context 'when count' do
        let(:payload) { { collection:  '$cmd', selector: { count: 'something' } } }

        its(:system_command?) { should be_false }
      end

      context 'when distinct' do
        let(:payload) { { collection:  '$cmd', selector: { distinct: 'something' } } }

        its(:system_command?) { should be_false }
      end

      context 'when other' do
        let(:payload) { { collection:  '$cmd', selector: { getnonce: -1 } } }

        its(:system_command?) { should be_true }
      end
    end

    describe '#system_any?' do
      pending
    end
  end
end
