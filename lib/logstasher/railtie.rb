require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module LogStasher
  class Railtie < Rails::Railtie
    config.logstasher = ActiveSupport::OrderedOptions.new
    config.logstasher.enabled = false

    initializer :logstasher do |app|
      if app.config.logstasher.enabled
        device = app.config.logstasher.device || STDOUT
        Rails.logger = LogStasher.logger = LogStasher::JSONLogger.new(device)
        LogStasher.setup(app)
        app.config.middleware.insert_after ActionDispatch::RequestId, LogStasher::Middleware
      end
    end
  end
end
