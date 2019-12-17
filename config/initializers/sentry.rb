# Setup Sentry
Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.processors -= [Raven::Processor::PostData] # Do this to send POST data
  config.processors -= [Raven::Processor::Cookies] # Do this to send cookies by default
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end