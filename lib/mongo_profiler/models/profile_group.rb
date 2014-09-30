module MongoProfiler
  class ProfileGroup
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String

    has_many :profiles

    index name: 1
  end
end
