# typed: false

require 'datadog/appsec/instrumentation/gateway'
require 'datadog/appsec/reactive/operation'
require 'datadog/appsec/contrib/rails/reactive/action'
require 'datadog/appsec/event'

module Datadog
  module AppSec
    module Contrib
      module Rails
        module Gateway
          # Watcher for Rails gateway events
          module Watcher
            def self.watch
              Instrumentation.gateway.watch('rails.request.action') do |stack, request|
                block = false
                event = nil
                waf_context = request.env['datadog.waf.context']

                AppSec::Reactive::Operation.new('rails.request.action') do |op|
                  trace = active_trace
                  span = active_span

                  Rails::Reactive::Action.subscribe(op, waf_context) do |action, result, _block|
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

                  _action, _result, block = Rails::Reactive::Action.publish(op, request)
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
