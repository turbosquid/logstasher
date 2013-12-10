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
      hash = {
        '@timestamp' => datetime.iso8601,
        '@fields' => {
          'request_id' => Rails.application.current_request_uuid,
          'level' => severity
        },
        '@tags' => []
      }

      case message
      when String
        hash.merge!({ '@message' => message })

      when Hash
        hash['@fields'].merge!(message)
        # promote nested tags to top level
        hash['@tags'] += message[:tags] || []

      when Exception
        hash['@tags'] << 'error'
        hash['@fields'].merge!(error: message.message, backtrace: message.backtrace)

      else
        if message.respond_to? :to_s
          hash.merge!( '@message' => message.to_s)
        else
          hash.merge!( '@message' => message.inspect)
        end
      end

      hash
    end

  end
end
