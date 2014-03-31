# Mongo Profiler

Database profiling tools are awesome and always useful. I love [Mongo Profiling](http://docs.mongodb.org/manual/tutorial/manage-the-database-profiler/). But unfortunately these tools don't match queries and code they are profiling, so sometimes isn't easy to match where the slow queries are performed.

The Mongo Profiler is a <del>refinement</del> patch in the [mongo-ruby-driver](https://github.com/mongodb/mongo-ruby-driver) to log all execute queries and their respective callers in a [capped collections](http://docs.mongodb.org/manual/core/capped-collections/).

It isn't competitor for the Mongo's built-in profiling, it is just a complementary tool to help us to profile our queries.

An interesting feature in the Mongo Profiler is that we can group queries by "life cycles". For example, in a web application it can be the `request_id`, so you will be able to see how many queries, how long did they take, the explain plans etc for a specific request.

First time I used it, I was shocked to see some pages doing lot of duplicated queries, even though some were really fast, they were unnecessary, I could get rid of some of them just by "memorising" some documents.

So, that is how Mongo Profiler could help you, showing what's really happening in your application.

## Sample App

* Sample Dashboard: https://mongo-profiler-sample-app.herokuapp.com/mongo_profiler
* Sample App: https://mongo-profiler-sample-app.herokuapp.com
* Sample App source code: https://github.com/phstc/mongo_profiler_sample_app

## Installation

Add this line to your application's Gemfile:

    gem 'mongo_profiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo_profiler

## Usage

### Rails application

To mount Mongo Profiler inside Rails, remember to add `gem 'sinatra', require: nil` in your Gemfile.


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
    # aggregate queries by request
    MongoProfiler.group_id = "request-#{request.uuid}"

    # to show the request url
    MongoProfiler.extra_attrs[:request_url]  = request.url
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

## Dashboard

The screenshots below are from the Mongo Profiler Dashboard. It is Rack application, which you can mount it in any other Rack application as detailed above or you could also start it directly as in the [config.ru example](https://github.com/phstc/mongo_profiler/blob/master/config.ru) in this repo.

### Screenshots

#### Dashboard index

![Dashboard Index](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_dashboard_index.png)

#### Queries Group Index

![Queries Group Index](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_group_details.png)

#### Query details

![Query Details](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_query_details.png)

#### Query details (backtrace)

![Query Details Backtrace](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_query_details_backtrace.png)


## Contributing

1. Fork it ( http://github.com/phstc/mongo_profiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
