require 'logger'

module LogStasher
  class JSONLogger < Logger

    attr_accessor :current_request_uuid

    def initialize(destination = STDOUT)
      super(destination)
      self.level = Logger::DEBUG
      self.formatter = proc do |severity, datetime, progname, message|
        if message.present?
          event = process_message(severity, datetime, message)
          serialize_event(event)
        end
      end
    end

    def process_message(severity, datetime, message)
      hash = message.to_logstash
      hash['@timestamp'] = datetime.iso8601
      hash['@fields'] ||= {}
      hash['@fields']['request_id'] = @current_request_uuid
      hash['@fields']['level'] = severity
      hash['@tags'] ||= []
      hash
    end

    private
    def serialize_oj(event)
      "#{Oj.dump(event, mode: :compat)}\n"
    end

    def serialize(event)
      "#{event.to_json}\n"
    end

    def self.define_serializer
      method = (defined? Oj) ? :serialize_oj : :serialize
      send(:alias_method, :serialize_event, method)
    end

    define_serializer

  end
end
