# typed: false

require 'datadog/appsec/instrumentation/gateway'
require 'datadog/appsec/reactive/operation'
require 'datadog/appsec/contrib/rack/reactive/request_body'
require 'datadog/appsec/contrib/sinatra/reactive/routed'
require 'datadog/appsec/event'

module Datadog
  module AppSec
    module Contrib
      module Sinatra
        module Gateway
          # Watcher for Rails gateway events
          module Watcher
            # rubocop:disable Metrics/MethodLength
            def self.watch
              Instrumentation.gateway.watch('sinatra.request.dispatch') do |stack, request|
                block = false
                event = nil
                waf_context = request.env['datadog.waf.context']

                AppSec::Reactive::Operation.new('sinatra.request.dispatch') do |op|
                  trace = active_trace
                  span = active_span

                  Rack::Reactive::RequestBody.subscribe(op, waf_context) do |action, result, _block|
                    record = [:block, :monitor].include?(action)
                    if record
                      # TODO: should this hash be an Event instance instead?
                      event = {
                        waf_result: result,
                        trace: trace,
                        span: span,
                        request: request,
                        action: action
                      }

                      waf_context.events << event
                    end
                  end

                  _action, _result, block = Rack::Reactive::RequestBody.publish(op, request)
                end

                next [nil, [[:block, event]]] if block

                ret, res = stack.call(request)

                if event
                  res ||= []
                  res << [:monitor, event]
                end

                [ret, res]
              end

              Instrumentation.gateway.watch('sinatra.request.routed') do |stack, (request, route_params)|
                block = false
                event = nil
                waf_context = request.env['datadog.waf.context']

                AppSec::Reactive::Operation.new('sinatra.request.routed') do |op|
                  trace = active_trace
                  span = active_span

                  Sinatra::Reactive::Routed.subscribe(op, waf_context) do |action, result, _block|
                    record = [:block, :monitor].include?(action)
                    if record
                      # TODO: should this hash be an Event instance instead?
                      event = {
                        waf_result: result,
                        trace: trace,
                        span: span,
                        request: request,
                        action: action
                      }

                      waf_context.events << event
                    end
                  end

                  _action, _result, block = Sinatra::Reactive::Routed.publish(op, [request, route_params])
                end

                next [nil, [[:block, event]]] if block

                ret, res = stack.call(request)

                if event
                  res ||= []
                  res << [:monitor, event]
                end

                [ret, res]
              end
            end
            # rubocop:enable Metrics/MethodLength

            class << self
              private

              def active_trace
                # TODO: factor out tracing availability detection

                return unless defined?(Datadog::Tracing)

                Datadog::Tracing.active_trace
              end

              def active_span
                # TODO: factor out tracing availability detection

                return unless defined?(Datadog::Tracing)

                Datadog::Tracing.active_span
              end
            end
          end
        end
      end
    end
  end
end
