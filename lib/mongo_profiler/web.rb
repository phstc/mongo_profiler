# https://github.om/mperham/sidekiq/wiki/Monitoring
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

    def load_collection_names
      @collection_names = MongoProfiler::Profile.command_collection_names
    end

    get '/' do
      load_collection_names

      @groups = MongoProfiler::ProfileGroup.order(:updated_at.desc)

      erb :groups
    end

    get '/groups/:id' do
      load_collection_names

      @group = MongoProfiler::ProfileGroup.find(params[:id])

      erb :group
    end

    post '/clear' do
      MongoProfiler::ProfileGroup.delete_all
      MongoProfiler::Profile.delete_all

      redirect to('/')
    end

    post '/clear_profile/:id' do
      profile = MongoProfiler::Profile.find(params[:id])
      profile_group_id = profile.profile_group_id

      profile.delete

      if MongoProfiler::Profile.where(profile_group_id: profile_group_id).limit(1).count(true) > 0
        redirect to("/groups/#{profile_group_id}")
      else
        MongoProfiler::ProfileGroup.find(id: profile_group_id).delete
        redirect to('/')
      end
    end

    get '/profiles' do
      load_collection_names

      @collection_name = params[:collection]

      profile_md5s = MongoProfiler::Profile.where(command_collection: @collection_name).distinct(:profile_md5)

      @profiles = MongoProfiler::Profile.in(profile_md5: profile_md5s)

      erb :profiles
    end

    get '/search' do
      redirect to("/profiles?collection=#{params[:collection]}")
    end
  end
end
