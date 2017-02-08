web: bundle exec puma -C config/puma.rb
release: bundle exec rake db:migrate
worker: bundle exec rake jobs:work
rake: bundle exec rake
console: bin/rails console