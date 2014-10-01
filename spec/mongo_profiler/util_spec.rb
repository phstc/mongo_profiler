require 'spec_helper'

module MongoProfiler
  describe Util do

    describe '.deep_keys' do
      it 'iterates over arrays' do
        hash = {
          key1: [{ 'key1_sub1' => 'key1_sub1_value', key1_sub2: [ 'key1_sub2_sub1' => {}] }, 'test'],
          key2: nil
        }

        expect(described_class.deep_keys(hash)).to eq([:key1, 'key1_sub1', :key1_sub2, 'key1_sub2_sub1', :key2])
      end

      it 'returns all keys' do
        hash = {
          key1: {
            key1_sub1: {
              key1_sub1_sub1: 'key1_sub1_sub1_value'
            },
            key1_sub2: 'key1_sub2_value',
            key1_sub3: {}
          },
          key2: {
            key2_sub1: {
              key2_sub1_sub1: 'key1_sub1_sub1_value',
              key2_sub1_sub2: {
                key2_sub1_sub2_sub1: {
                  key2_sub1_sub2_sub1_sub1: {}
                }
              }
            },
            key2_sub2: 'key2_sub2_value',
            key2_sub3: 'key2_sub3_value',
            key2_sub4: 'key2_sub4_value',
            key2_sub5: 'key2_sub5_value'
          }
        }

        expect(described_class.deep_keys(hash)).to eq(%i[key1 key1_sub1 key1_sub1_sub1
                                                      key1_sub2 key1_sub3 key2 key2_sub1
                                                      key2_sub1_sub1 key2_sub1_sub2
                                                      key2_sub1_sub2_sub1 key2_sub1_sub2_sub1_sub1
                                                      key2_sub2 key2_sub3 key2_sub4 key2_sub5])
      end
    end
  end
end
