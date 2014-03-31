require 'mongo'
require 'mongo_profiler'
require 'mongo_profiler/web'

client = Mongo::MongoClient.new
DB     = client.db('sample_app_database')


MongoProfiler.setup_database(DB)
# or
# MongoProfiler.connect('localhost', 27017, 'sample_app_database')

run MongoProfiler::Web