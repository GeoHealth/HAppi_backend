# Sentry configuration for error reporting
Raven.configure do |config|
  if ENV['SENTRY_DSN']
    config.dsn = ENV['SENTRY_DSN']
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  else
      puts 'Sentry will not be active for this session because no SENTRY_DSN was given'
  end
end