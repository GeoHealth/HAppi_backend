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
4. `gem install mailcatcher`

## Run local server

Start he rails server with 
`rails s`

And start the mailcatcher server with
`mailcatcher`

The mails can then be seen at [http://localhost:1080/](http://localhost:1080/)

## Testing

### Preparation
`rake db:test:prepare`

### Simple run
`rake spec`