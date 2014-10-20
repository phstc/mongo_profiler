require 'spec_helper'

module MongoProfiler
  describe Caller do
    describe '.command_collection_names' do
      it 'returns collection names' do
        TestModel.first
        TestModel.last

        TestSuperModel.first

        expect(MongoProfiler::Profile.command_collection_names).to eq([{ '_id' => 'test_models', 'value' => 2.0 }, { '_id' => 'test_super_models', 'value' => 1.0 }])
      end
    end

    describe '#command_order_by_keys' do
      it 'returns order_by' do
        TestModel.order_by(:name.asc).first

        profile = MongoProfiler::Profile.last
        expect(profile.command_order_by_keys).to eq ['name.asc']
      end

      it 'returns order_by without query by' do
        TestModel.where(name: 'Pablo', last_name: 'Cantero').order_by(:name.asc, :last_name.desc).first

        profile = MongoProfiler::Profile.last
        expect(profile.command_order_by_keys).to eq %w[name.asc last_name.desc]
      end
    end

    describe '#command_query_keys' do
      it 'returns query' do
        TestModel.where(name: 'Pablo', last_name: 'Cantero').and.gt(test1: 1).or(test2: /a/).first

        profile = MongoProfiler::Profile.last
        expect(profile.command_query_keys).to eq %w[name last_name test1 test2]
      end

      it 'returns query without order by' do
        TestModel.where(name: 'Pablo', last_name: 'Cantero').order(:_name.asc).first

        profile = MongoProfiler::Profile.last
        expect(profile.command_query_keys).to eq %w[name last_name]
      end
    end

    describe '#file_reference' do
      it 'returns the file reference' do
        TestModel.where(name: 'Pablo').first

        profile = MongoProfiler::Profile.last
        expect(profile.file_reference).to eq "profile_spec.rb:#{profile.line}"
      end
    end

    describe '#full_file_reference' do
      it 'returns the full file reference' do
        TestModel.where(name: 'Pablo').first

        profile = MongoProfiler::Profile.last
        expect(profile.full_file_reference).to eq "#{__FILE__}:#{profile.line}"
      end
    end

    describe '.register' do
      it 'creates a profile' do
        test = TestModel.create(name: 'Pablo')

        expect(TestModel.where(name: 'Pablo').first.name).to eq 'Pablo'

        expect(MongoProfiler::ProfileGroup.count).to eq 1

        group = MongoProfiler::ProfileGroup.first
        expect(group.name).to eq 'Undefined group name'

        expect(MongoProfiler::Profile.count).to eq 1

        profile = MongoProfiler::Profile.first

        expect(profile.attributes).to include('profile_group_id' => group.id,
                                              'file' => __FILE__,
                                              'command_database' => 'mongo_profiler_test',
                                              'command_collection' => 'test_models')

        expect(JSON.parse(profile.command)).to eq('$query' => { 'name' => 'Pablo' }, '$orderby' => { '_id' => 1 })

        expect(profile.score).to eq :perfect
      end

      it 'does not duplicate profiles' do
        test = TestModel.create

        # To guarantee the same line number
        TestModel.where(name: 'Pablo').first || TestModel.where(name: 'Pablo').first

        expect(MongoProfiler::ProfileGroup.count).to eq 1
        expect(MongoProfiler::Profile.count).to eq 1
      end

      it 'creates a new profile if the query keys change' do
        test = TestModel.create

        TestModel.where(name: 'Pablo').first
        TestModel.where(last_name: 'Cantero').first

        expect(MongoProfiler::ProfileGroup.count).to eq 1
        expect(MongoProfiler::Profile.count).to eq 2
      end

      it 'uses supplied group name' do
        MongoProfiler.current_group_name = 'Test'

        test = TestModel.create(name: 'Pablo')

        TestModel.where(name: 'Pablo').first

        expect(MongoProfiler::ProfileGroup.count).to eq 1

        group = MongoProfiler::ProfileGroup.first
        expect(group.name).to eq 'Test'
      end
    end
  end
end
