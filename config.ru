require 'pry-byebug'
require 'mongo'
require 'mongo_profiler'

require 'mongo_profiler/web'

CONNECTION = Mongo::MongoClient.new
DB         = CONNECTION.db('mongo_profiler-database')
COLL       = DB['example-collection']

MongoProfiler.connect('localhost', 27017, 'mongo_profiler-database')

run MongoProfiler::Web