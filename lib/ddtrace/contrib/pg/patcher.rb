require 'ddtrace/contrib/patcher'
require 'ddtrace/contrib/pg/connection'

module Datadog
  module Contrib
    module Pg
      # Patcher enables patching of 'pg' module.
      module Patcher
        include Contrib::Patcher

        module_function

        def patched?
          done?(:pg)
        end

        def patch
          ::PG::Connection.send(:include, Connection)
        end
      end
    end
  end
end
