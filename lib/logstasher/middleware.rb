#
# Add this middleware to your rails project
# to carry the request uuid through to various logged events
# ex:
# config.middleware.insert_after ActionDispatch::RequestId, LogStasher::RequestTracker
#

module LogStasher
  class Middleware
    def initialize(app, *args)
      @app = app
    end

    def call(env)
      Rails.logger.current_request_uuid = env['action_dispatch.request_id']
      @app.call(env)
    ensure
      Rails.logger.current_request_uuid = nil
    end
  end
end
