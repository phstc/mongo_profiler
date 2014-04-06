# Mongo Profiler

[![Build Status](https://travis-ci.org/phstc/mongo_profiler.svg)](https://travis-ci.org/phstc/mongo_profiler)

**Mongo profiling tool which matches queries with code**

Database profiling tools are awesome and always useful. I love [Mongo profiling](http://docs.mongodb.org/manual/tutorial/manage-the-database-profiler/). But unfortunately these tools don't match the queries with the source code they are profiling, making hard to find where the slow queries are executed.

The Mongo Profiler is a <del>refinement</del> patch in the [mongo-ruby-driver](https://github.com/mongodb/mongo-ruby-driver) to log all executed queries and their respective callers ([Ruby backtrace](http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-caller)) in a [capped collections](http://docs.mongodb.org/manual/core/capped-collections/).

It isn't replacement for the Mongo's built-in profiling, it is just a complementary tool to profile the queries with their respective source code.

An interesting feature in the Mongo Profiler is that we can group queries by "life cycles". For example, in a web application it can be the `request_id`, so you will be able to see how many queries, how long did they take, the explain plans etc for each request.

## Sample App

You can see how it works through the [Sample Dashboard](https://mongo-profiler-sample-app.herokuapp.com/mongo_profiler) and [Sample App](https://mongo-profiler-sample-app.herokuapp.com) ([source code](https://github.com/phstc/mongo_profiler_sample_app)).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongo_profiler'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install mongo_profiler
```

To run the Dashboard you will need also to install [sinatra](https://github.com/sinatra/sinatra).

```ruby
gem 'sinatra', require: nil
```

## Usage

### Rails application

#### Mongo Profiler initializer

```ruby
# config/initializers/mongo_profiler_setup.rb

require 'mongo_profiler'
require 'mongo_profiler/extensions/mongo/cursor'

MongoProfiler.setup_database(MY_DATABASE_CONNECTION)
# or
# MongoProfiler.connect('localhost', 27017, 'my_database')

MongoProfiler.application_name = 'my_application'

# To enable Statsd
# MongoProfiler.stats_client = MyStatsdClientInstance

# To show graphite graphs
# MongoProfiler.graphite_url = 'http://my_graphite'
```

#### ApplicationController setup

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

#### Dashboard app

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
## Standalone Dashboard

You can mount the Dashboard outside your main application using [config.ru example](https://github.com/phstc/mongo_profiler/blob/master/config.ru).

Then:

```bash
$ rackup
```

Make sure to connect to the same database your Mongo Profiler is connected to.

### Screenshots

#### Dashboard index

![Dashboard Index](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_dashboard_index.png)

#### Queries Group Index

![Queries Group Index](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_group_details.png)

#### Query details

TODO: Show a Graphite/StatsD example.

![Query Details](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_query_details.png)

#### Query details (backtrace)

![Query Details Backtrace](https://raw.github.com/phstc/mongo_profiler/master/assets/mongo_profiler_query_details_backtrace.png)


## TODO

* Support Mongoid
* Background processing to recommend indexes
* Show Graphite/Statsd example

## Contributing

1. Fork it ( http://github.com/phstc/mongo_profiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request