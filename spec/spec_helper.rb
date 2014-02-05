require 'bundler/setup'
require 'pry-byebug'

Bundler.require(:default, :test)

require_relative '../lib/mongo_profiler'

CONNECTION = Mongo::Connection.new
DB         = CONNECTION.db('mongo_profiler-database-test')
COLL       = DB['example-collection']

Dir['./spec/support/**/*.rb'].each &method(:require)

MongoProfiler.database = DB
MongoProfiler.application_name = 'project'

RSpec.configure do |config|
  config.after do
    DB.collections.each do |collection|
      collection.drop unless collection.name.match(/^system\./)
    end

    # creates capped collections
    MongoProfiler.create_collections
  end
end
