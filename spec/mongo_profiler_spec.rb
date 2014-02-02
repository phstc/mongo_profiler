require 'spec_helper'

describe MongoProfiler do
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
end
