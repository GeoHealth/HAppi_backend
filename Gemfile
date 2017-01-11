source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
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

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # On windows there is an error about timezone
  # #https://github.com/tzinfo/tzinfo/wiki/Resolving-TZInfo::DataSourceNotFound-Errors
  gem 'tzinfo-data', '~> 1.2016', '>= 1.2016.10'

  # Rspec test
  gem 'rspec-rails', '~> 3.5'
end

group :test do
  # https://github.com/thoughtbot/shoulda-matchers
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'

  # Need to add the Rake gem in the Gemfile for Travis-CI
  # https://docs.travis-ci.com/user/languages/ruby#Default-Test-Script
  gem 'rake', '~> 12.0'

  # Test-coverage
  # https://docs.codeclimate.com/docs/ruby
  gem "simplecov"
  gem "codeclimate-test-reporter", "~> 1.0.0"
end

