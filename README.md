HAppi backend
=============

[![Build Status](https://travis-ci.org/GeoHealth/HAppi_backend.svg?branch=master)](https://travis-ci.org/GeoHealth/HAppi_backend)
[![Code Climate](https://codeclimate.com/github/GeoHealth/happi_backend/badges/gpa.svg)](https://codeclimate.com/github/GeoHealth/happi_backend)
[![Test Coverage](https://codeclimate.com/github/GeoHealth/happi_backend/badges/coverage.svg)](https://codeclimate.com/github/GeoHealth/happi_backend/coverage)
[![Issue Count](https://codeclimate.com/github/GeoHealth/happi_backend/badges/issue_count.svg)](https://codeclimate.com/github/GeoHealth/happi_backend)

Rails application to run the REST API of the HAppi application.

## Quick start

1. `bundle install`
2. `rake db:migrate`
3. `rake db:seed`
4. `rails s`

## Run local server

Install mailcatcher to intercept mails 

    gem install mailcatcher

Start the rails server with 
    
    rails s
    
Start sidekiq with

    bundle exec sidekiq -q default -q mailers

And start the mailcatcher server with

    mailcatcher

The mails can then be seen at [http://localhost:1080/](http://localhost:1080/)

The sidekiq dashboard can be seen at [http://localhost:3000/sidekiq](http://localhost:3000/sidekiq)

## Production

### Environment variables
The following environment variables are needed:

- MAILGUN_API_KEY
- MAILGUN_DOMAIN
- RAILS_ENV=production
- SENTRY_DSN
- WUNDERGROUND_API_KEY
- ELASTIC_URL
- DEPLOY_TASKS="db:migrate"
- DEVISE_SECRET_KEY
    - To generate it, use `rake secret`

### Databases
- A Redis database is needed.
- A PostgreSQL database is needed.

## Testing

### Preparation

    rake db:test:prepare

### Simple run

    rake spec

### Rspec documentation
We can generate some kind of documentation using the Rpsec tests because we described them nicely.

    rspec --format documentation --out rspec.txt