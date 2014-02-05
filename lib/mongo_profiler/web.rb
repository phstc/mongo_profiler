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
      @profiles = MongoProfiler.collection.
        group({ key:     %i[method file application_name group_id],
                reduce:  'function(curr, result) { result.total_time += curr.total_time; result.total += 1 }',
                initial: { total: 0, total_time: 0 } })

      # group profilers by group_id and sort by created_at DESC
      @grouped_profiles = @profiles.group_by { |profile| profile['group_id'] }.to_a.reverse

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

    get '/profiler/groups/:group_id' do
      @group_id = params[:group_id]
      @profiles = MongoProfiler.collection.find(group_id: @group_id).to_a

      @sample_profile = @profiles.first

      @profiles_count = @profiles.count
      @profiles_total_time = @profiles.reduce(0) { |sum, p| sum + p['total_time'] }

      @grouped_profiles = @profiles.group_by { |profile| profile['method'] }

      erb :group_id
    end
  end
end
