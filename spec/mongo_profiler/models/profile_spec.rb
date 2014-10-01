require 'spec_helper'

module MongoProfiler
  describe Caller do
    it 'creates a profile' do
      test = TestModel.create(name: 'Pablo')

      expect(TestModel.where(name: 'Pablo').first.name).to eq 'Pablo'


      expect(MongoProfiler::ProfileGroup.count).to eq 1

      group = MongoProfiler::ProfileGroup.first
      expect(group.name).to eq 'Undefined group name'

      expect(MongoProfiler::Profile.count).to eq 1
      # TODO check all the stuff
      expect(MongoProfiler::Profile.first.attributes).to include('profile_group_id' => group.id)
    end

    it 'does not duplicate profiles' do
      test = TestModel.create

      TestModel.where(name: 'Pablo').first
      TestModel.where(name: 'Pablo').first

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
  end
end
