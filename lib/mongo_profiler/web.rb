# https://github.com/mperham/sidekiq/wiki/Monitoring
require 'erb'
require 'yaml'
require 'sinatra/base'
require 'json'

require 'mongo_profiler/web_helpers'

module MongoProfiler
  class Web < Sinatra::Base

    set :root,           File.expand_path(File.dirname(__FILE__) + "/../../web")
    set :public_folder,  Proc.new { "#{root}/assets" }
    set :views,          Proc.new { "#{root}/views" }

    helpers WebHelpers


    get '/' do
      erb :index
    end

    post '/profiler/enable' do
      MongoProfiler.enable!

      redirect to('/settings')
    end

    post '/profiler/disable' do
      MongoProfiler.disable!

      redirect to('/settings')
    end

    get '/settings' do
      begin
        @collection_config_stats   = JSON.pretty_generate MongoProfiler.collection_config.stats
        @collection_profiler_stats = JSON.pretty_generate MongoProfiler.collection.stats
      rescue Mongo::OperationFailure => e
        if e.message.match /ns not found/
          MongoProfiler.create_collections
          # TODO Ask before create collections
          redirect to('/settings')
        else
          @error_alert = e.message
        end
      end

      erb :settings
    end
  end
end
