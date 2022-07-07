# typed: false

require 'datadog/tracing/contrib/configuration/settings'
require 'datadog/tracing/contrib/pg/ext'

module Datadog
  module Tracing
    module Contrib
      module Pg
        module Configuration
          # Custom settings for the PG integration
          class Settings < Contrib::Configuration::Settings
            option :service_name, default: Ext::SERVICE_NAME
          end
        end
      end
    end
  end
end
