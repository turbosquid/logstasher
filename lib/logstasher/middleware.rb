# captures the request id at the routing layer so all inbound calls
# have the correct request id, when logged

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
