# typed: false

require 'datadog/tracing/contrib/patcher'
require 'datadog/tracing/contrib/pg/connection'

module Datadog
  module Tracing
    module Contrib
      module Pg
        # Patcher enables patching of 'pg' module.
        module Patcher
          include Contrib::Patcher

          module_function

          def target_version
            Integration.version
          end

          def patch
            ::PG::Connection.send(:include, Connection)
          end
        end
      end
    end
  end
end
