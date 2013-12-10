require 'logger'

module LogStasher
  class JSONLogger < Logger

    def initialize(destination = STDOUT)
      super(destination)
      self.level = Logger::DEBUG
      self.formatter = proc do |severity, datetime, progname, message|
        if message.present?
          data = process_message(severity, datetime, message)
          event = LogStash::Event.new(data)
          "#{event.to_json}\n"
        end
      end
    end

    def process_message(severity, datetime, message)
      hash = message.to_logstash
      hash['@timestamp'] = datetime.iso8601
      hash['@fields'] ||= {}
      hash['@fields']['request_id'] = Rails.application.current_request_uuid
      hash['@fields']['level'] = severity
      hash['@tags'] ||= []
      hash
    end

  end
end
