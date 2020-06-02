# frozen_string_literal: true

schedule_file = 'config/schedule.yml'

if File.exist?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

Sidekiq.default_worker_options = { 'backtrace' => true }
