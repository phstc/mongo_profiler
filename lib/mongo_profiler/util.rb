module MongoProfiler
  class Util
    class << self
      def deep_keys(hash)
        return [] unless hash.is_a? Hash

        hash.inject([]) do |keys, (key, value)|
          keys << key
          case value
          when Hash
            keys.concat deep_keys(value)
          when Array
            value.each { |vvalue| keys.concat deep_keys(vvalue) }
          end

          keys
        end
      end
    end
  end
end
