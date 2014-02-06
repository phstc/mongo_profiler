require 'pry-byebug'
require 'mongo'
require 'mongo_profiler'

require 'mongo_profiler/web'

CONNECTION = Mongo::Connection.new
DB         = CONNECTION.db('mongo_profiler-database')
COLL       = DB['example-collection']

MongoProfiler.database = DB

run MongoProfiler::Web