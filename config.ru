require 'mongo'
require 'mongo_profiler'
require 'mongo_profiler/web'

client = Mongo::MongoClient.new
MY_DATABASE_CONNECTION = client.db('sample_app_database')


MongoProfiler.setup_database(MY_DATABASE_CONNECTION)
# or
# MongoProfiler.connect('localhost', 27017, 'sample_app_database')

run MongoProfiler::Web