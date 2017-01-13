#!/bin/bash

DEFAULT_ENVIRONMENT="development"
ENVIRONMENT="${1:-$DEFAULT_ENVIRONMENT}"

echo "Executing startup script for $ENVIRONMENT environment"

echo "Installing gems"
bundle install

echo "Creating database"
RAILS_ENV=${ENVIRONMENT} rake db:create

echo "Executing migrations"
RAILS_ENV=${ENVIRONMENT} rake db:migrate

echo "Populating database with seeds.rb"
RAILS_ENV=${ENVIRONMENT} rake db:seed

echo "Starting server in $ENVIRONMENT mode"
nohup rails s -e ${ENVIRONMENT} > backend.log 2>&1&
echo $! > rails_pid
