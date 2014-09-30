module MongoProfiler
  class ProfileGroup
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String

    has_many :profiles, dependent: :delete

    index name: 1
  end
end
