require 'logger'

module LogStasher
  class JSONLogger < Logger

    def initialize(destination = STDOUT)
      super(destination)
      self.level = Logger::DEBUG
      self.formatter = proc do |severity, datetime, progname, message|
        if message.present?
          event = process_message(severity, datetime, message)
          (defined? Oj) ? "#{Oj.dump(event, mode: :compat)}\n" : "#{event.to_json}\n"
        end
      end
    end

    def process_message(severity, datetime, message)
      hash = message.to_logstash
      hash['@timestamp'] = datetime.iso8601
      hash['@fields'] ||= {}
      if Rails.application.respond_to? :current_request_uuid
        hash['@fields']['request_id'] = Rails.application.current_request_uuid
      end
      hash['@fields']['level'] = severity
      hash['@tags'] ||= []
      hash
    end

  end
end
