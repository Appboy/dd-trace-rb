# typed: false

require 'datadog/tracing/contrib/integration'
require 'datadog/tracing/contrib/pg/configuration/settings'
require 'datadog/tracing/contrib/pg/patcher'

module Datadog
  module Tracing
    module Contrib
      module Pg
        # Description of PG integration
        class Integration
          include Contrib::Integration

          MINIMUM_VERSION = Gem::Version.new('1.3.5')

          # @public_api Changing the integration name or integration options can cause breaking changes
          register_as :pg

          def self.version
            Gem.loaded_specs['pg'] && Gem.loaded_specs['pg'].version
          end

          def self.loaded?
            !defined?(::Pg).nil?
          end

          def self.compatible?
            super && version >= MINIMUM_VERSION
          end

          def new_configuration
            Configuration::Settings.new
          end

          def patcher
            Patcher
          end
        end
      end
    end
  end
end
