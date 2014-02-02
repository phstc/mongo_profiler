require 'bundler/setup'
require 'pry-byebug'

Bundler.require(:default, :test)

require_relative '../lib/mongo_profiler'

CONNECTION = Mongo::Connection.new # defaults to localhost:27017
DB         = CONNECTION.db('mongo_profiler-database-test')
COLL       = DB['example-collection']

Dir['./spec/support/**/*.rb'].each &method(:require)

# creates capped collections
MongoProfiler::Profiler.new(DB).create_collections

RSpec.configure do |config|
  config.after do
    DB.collections.each do |collection|
      collection.drop unless collection.name.match(/^system\./)
    end
  end
end
