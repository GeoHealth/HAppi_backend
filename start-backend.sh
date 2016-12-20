#!/bin/bash

bundle install
rake db:create
rake db:migrate
nohup rails s > backend.log &

