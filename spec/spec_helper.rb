require 'bundler/setup'
require 'pry-byebug'

Bundler.require(:default, :test)

require_relative '../lib/mongo_profiler'

# CONNECTION = Mongo::MongoClient.new
# DB         = CONNECTION.db('mongo_profiler-database-test')
# COLL       = DB['example-collection']

Dir['./spec/support/**/*.rb'].each &method(:require)

RSpec.configure do |config|
  config.before do
    # MongoProfiler.connect('localhost', 27017, 'mongo_profiler-database-test')

    # creates capped collections
    # MongoProfiler.create_collections
  end

  config.after do
    # DB.collections.each do |collection|
      # collection.drop unless collection.name.match(/^system\./)
    # end
  end
end
