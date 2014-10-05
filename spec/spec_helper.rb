require 'bundler/setup'
require 'pry-byebug'
require 'database_cleaner'
require 'mongo_profiler'

Bundler.require(:default, :test)

ENV['MONGOID_ENV'] = 'test'

Mongoid.load!(File.join(File.dirname(__FILE__), 'mongoid.yml'))

class TestModel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
end

class TestSuperModel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
end

Dir['./spec/support/**/*.rb'].each &method(:require)

RSpec.configure do |config|
  config.before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
