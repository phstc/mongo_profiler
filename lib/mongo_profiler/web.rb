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
  end
end
