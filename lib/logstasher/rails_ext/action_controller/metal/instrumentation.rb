module ActionController
  module Instrumentation
    def process_action(*args)
      raw_payload = {
          :controller => self.class.name,
          :action     => self.action_name,
          :params     => request.filtered_parameters,
          :format     => request.format.try(:ref),
          :method     => request.method,
          :path       => (request.fullpath rescue "unknown")
      }

      LogStasher.add_default_fields_to_payload(raw_payload, request)
      if self.respond_to?(:logtasher_add_custom_fields_to_payload)
        before_keys = raw_payload.keys.clone
        logtasher_add_custom_fields_to_payload(raw_payload)
        after_keys = raw_payload.keys
        # Store all extra keys added to payload hash in payload itself. This is a thread safe way
        LogStasher.custom_fields += after_keys - before_keys
      end

      ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload)

      ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
        result = super
        payload[:status] = response.status
        append_info_to_payload(payload)
        result
      end
    end

  end
end
