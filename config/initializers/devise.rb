require "devise"
require "devise/orm/active_record"

Devise.setup do |config|
  config.mailer_sender = "please-change-me@example.com"
  config.navigational_formats = ["*", :html, :turbo_stream]
  config.parent_controller = "ApplicationController"
  config.secret_key = Rails.application.secret_key_base
  # Sign out via DELETE only (default, safer against CSRF).
  config.sign_out_via = :delete
end
