web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
rake: bundle exec rake
console: bin/rails console
sidekiq-mailer: bundle exec sidekiq -q default -q mailers