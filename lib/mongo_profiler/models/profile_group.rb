module MongoProfiler
  class ProfileGroup
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String

    has_many :profiles, dependent: :delete

    index name: 1

    def total_time
      profiles.sum(&:total_time)
    end

    def avg_time
      return 0 if (count = profiles.count) == 0
      total_time / count
    end

    def min_time
      profiles.collect(&:total_time).min
    end

    def max_time
      profiles.collect(&:total_time).max
    end

    def filter_by_score(score)
      profiles.select do |p|
        p.score == score
      end
    end

    def count_by_score(score)
      filter_by_score(score).size
    end
  end
end
