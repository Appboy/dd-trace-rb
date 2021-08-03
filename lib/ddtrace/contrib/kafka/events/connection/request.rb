require 'ddtrace/contrib/kafka/ext'
require 'ddtrace/contrib/kafka/event'

module Datadog
  module Contrib
    module Kafka
      module Events
        module Connection
          # Defines instrumentation for request.connection.kafka event
          module Request
            include Kafka::Event

            EVENT_NAME = 'request.connection.kafka'.freeze

            def self.process(span, _event, _id, payload)
              super

              span.resource = payload[:api]

              span.set_tag(Ext::TAG_REQUEST_SIZE, payload[:request_size]) if payload.key?(:request_size)
              span.set_tag(Ext::TAG_RESPONSE_SIZE, payload[:response_size]) if payload.key?(:response_size)
            end

            module_function

            def span_name
              Ext::SPAN_CONNECTION_REQUEST
            end
          end
        end
      end
    end
  end
end
