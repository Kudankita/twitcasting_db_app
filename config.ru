# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end

run Rails.application
