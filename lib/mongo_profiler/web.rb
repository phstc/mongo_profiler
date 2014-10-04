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


    get '/' do
      @groups = MongoProfiler::ProfileGroup.order(:updated_at.desc)

      erb :index
    end

    get '/groups/:id' do
      @group = MongoProfiler::ProfileGroup.find(params[:id])

      erb :show
    end

    post '/clear' do
      MongoProfiler::ProfileGroup.delete_all
      MongoProfiler::Profile.delete_all

      redirect to('/')
    end

    get '/profiles' do
      @collection_name = params[:collection]

      profile_md5s = MongoProfiler::Profile.where(command_collection: @collection_name).distinct(:profile_md5)

      @profiles = MongoProfiler::Profile.in(profile_md5: profile_md5s)

      erb :search
    end

    get '/search' do
      redirect to("/profiles?collection=#{params[:collection]}")
    end
  end
end
