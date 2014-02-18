# MongoProfiler

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'mongo_profiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo_profiler

## Usage

### Rails application

```ruby
# config/initializers/mongo_profiler_setup.rb

require 'mongo_profiler'
require 'mongo_profiler/extensions/mongo/cursor'

MongoProfiler.connect('localhost', 27017, 'my_database')

MongoProfiler.application_name = 'my_application'

# To enable Statsd
# MongoProfiler.stats_client = MyStatsdClientInstance

# To show graphite graphs
# MongoProfiler.graphite_url = 'http://my_graphite'
```

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_filter :mongo_profiler_setup

  private

  def mongo_profiler_setup
    # aggreated queries by request
    MongoProfiler.group_id = "request-#{request.uuid}"

    MongoProfiler.extra_attrs[:request_url]  = request.url
  rescue => e
    p "MongoProfiler: #{e.message}"
  end
end
```

```ruby
# config/routes.rb

require 'mongo_profiler/web'

MyApplication::Application.routes.draw do
  mount MongoProfiler::Web => '/mongo_profiler'

  # Security with Devise
  # authenticate :user do
  #  mount MongoProfiler::Web => '/mongo_profiler'
  # end
  #
  # authenticate :user, lambda { |u| u.admin? } do
  #  mount MongoProfiler::Web => '/mongo_profiler'
  # end
end
```

## Contributing

1. Fork it ( http://github.com/phstc/mongo_profiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
