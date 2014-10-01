# Mongo Profiler

[![Build Status](https://travis-ci.org/phstc/mongo_profiler.svg)](https://travis-ci.org/phstc/mongo_profiler)

**Mongo profiling tool which matches queries with code**

Database profiling tools are awesome and always useful. I love [Mongo profiling](http://docs.mongodb.org/manual/tutorial/manage-the-database-profiler/). But unfortunately these tools don't match the queries with the source code they are profiling, making hard to find where the slow queries are executed.

The Mongo Profiler is a <del>refinement</del> patch in the [moped driver](https://github.com/mongoid/moped) to log all executed queries and their respective callers ([Ruby backtrace](http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-caller)).

It isn't replacement for the Mongo's built-in profiling, it is just a complementary tool to profile the queries with their respective source code.

An interesting feature in the Mongo Profiler is that we can group queries by "life cycles". For example, in a web application it can be the `request.uuid` or the `request.url`, so you will be able to see how many queries, how long did they take, the explain plans etc for each request or url.

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

### Gemfile

```
gem 'mongo_profiler', github: 'phstc/mongo_profiler', require: nil
gem 'sinatra', require: nil
```

#### application_controller.rb

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_filter :set_mongo_profile_group_name

  def set_mongo_profile_group_name
    unless Rails.env.production?
      require 'mongo_profiler'
      MongoProfiler.current_group_name = request.url
    end
  end
end
```

#### routes.rb

```ruby
# config/routes.rb

MyApplication::Application.routes.draw do
  unless Rails.env.production?
    require 'mongo_profiler'
    require 'mongo_profiler/web'
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
end
```

## Contributing

1. Fork it ( http://github.com/phstc/mongo_profiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request