Moped::Node.class_eval do
  alias_method :original_query, :query

  def query(database, collection, selector, options = {})
    started_at = Time.now

    result = original_query(database, collection, selector, options)

    begin
      MongoProfiler::Profile.register(started_at, database, collection, selector, options)
    rescue => e
      p "MongoProfiler ERROR: #{e.message}\ncollection: #{collection}\nselector: #{selector}\noptions: #{options}"
    end

    result
  end
end
