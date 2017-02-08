source 'https://rubygems.org'

# Explicitly set the Ruby version to 2.2.x
ruby '>= 2.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.19.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Rack::Cors provides support for Cross-Origin Resource Sharing (CORS)
# http://stackoverflow.com/questions/29751115/how-to-enable-cors-in-rails-4-app
gem 'rack-cors', '0.4'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use for authentication
# https://github.com/lynndylanhurley/devise_token_auth
gem 'devise_token_auth'

# Puma gem for multi threaded server
gem 'puma'

# This gem enables serving assets in production and setting your logger to standard out
gem 'rails_12factor', group: :production

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # On windows there is an error about timezone
  # #https://github.com/tzinfo/tzinfo/wiki/Resolving-TZInfo::DataSourceNotFound-Errors
  gem 'tzinfo-data', '~> 1.2016', '>= 1.2016.10'

  # Rspec test
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  # https://github.com/thoughtbot/shoulda-matchers
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'

  # Need to add the Rake gem in the Gemfile for Travis-CI
  # https://docs.travis-ci.com/user/languages/ruby#Default-Test-Script
  gem 'rake', '~> 12.0'

  # Test-coverage
  # https://docs.codeclimate.com/docs/ruby
  gem 'simplecov'
  gem 'codeclimate-test-reporter', '~> 1.0.0'

  # Use Factories instead of Fixtures: https://semaphoreci.com/blog/2014/01/14/rails-testing-antipatterns-fixtures-and-factories.html
  # https://github.com/thoughtbot/factory_girl_rails
  gem 'factory_girl_rails', '~> 4.8'
end

