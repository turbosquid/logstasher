require 'logstasher/version'
require 'logstasher/log_subscriber'
require 'logstasher/json_logger'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/ordered_options'
require 'logstasher/core_ext/logstash_serializer'
require 'logstasher/middleware'

module LogStasher
  # Logger for the logstash logs
  mattr_accessor :logger, :enabled

  def self.add_default_fields_to_payload(payload, request)
    payload[:ip] = request.remote_ip
    payload[:route] = "#{request.params[:controller]}##{request.params[:action]}"
    payload[:parameters] = payload[:params].except(*ActionController::LogSubscriber::INTERNAL_PARAMS).inject(""){|s,(k,v)|
      s+="#{k}=#{v}\n"}
    self.custom_fields += [:ip, :route, :parameters]
  end

  def self.add_custom_fields(&block)
    ActionController::Metal.send(:define_method, :logtasher_add_custom_fields_to_payload, &block)
    ActionController::Base.send(:define_method, :logtasher_add_custom_fields_to_payload, &block)
  end

  def self.setup(app)
    # patch instrumentation class to insert our hook
    require 'logstasher/rails_ext/action_controller/metal/instrumentation'
    LogStasher::RequestLogSubscriber.attach_to :action_controller
  end

  def self.log(severity, msg)
    self.logger.send(severity, message)
  end

  def self.custom_fields
    Thread.current[:logstasher_custom_fields] ||= []
  end

  def self.custom_fields=(val)
    Thread.current[:logstasher_custom_fields] = val
  end

  def self.log(severity, msg)
    self.logger.send(severity, event.to_json)
  end

  class << self
    %w( fatal error warn info debug unknown ).each do |severity|
      eval <<-EOM, nil, __FILE__, __LINE__ + 1
        def #{severity}(msg)
          self.log(:#{severity}, msg)
        end
      EOM
    end
  end
end

require 'logstasher/railtie' if defined?(Rails)
