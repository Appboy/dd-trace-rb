# typed: false

require 'datadog/tracing/metadata/ext'
require 'datadog/tracing/contrib/pg/ext'

module Datadog
  module Contrib
    module Pg
      # PG::Connection patch module
      module Connection
        module_function

        def included(base)
          base.send(:prepend, InstanceMethods)
        end

        # PG::Connection patch instance methods
        module InstanceMethods

          # sync_exec(sql) -> PG::Result
          # sync_exec(sql) {|pg_result| block}
          def sync_exec(sql)
            service = Datadog.configuration_for(self, :service_name) || datadog_configuration[:service_name]
            Tracing.trace(Ext::SPAN_QUERY, service: service) do |span|
              span.resource = sql
              span.span_type = Tracing::Metadata::Ext::SQL::TYPE
              span.set_tag(Ext::TAG_DB_NAME, db)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_HOST, host)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_PORT, port)
              super # this will pass all args, including the block
            end
          end

          # sync_exec_params(sql, params[, result_format[, type_map]] ) -> PG::Result
          # sync_exec_params(sql, params[, result_format[, type_map]] ) {|pg_result| block }
          # exec_params (and async version) is parsed with rb_scan_args like so:
          # rb_scan_args(argc, argv, "22", &command, &paramsData.params, &in_res_fmt, &paramsData.typemap);
          # meaning it expects 2 required arguments and 2 explicit optional
          def sync_exec_params(sql, params, result_format = nil, type_map = nil)
            service = Datadog.configuration_for(self, :service_name) || datadog_configuration[:service_name]
            Tracing.trace(Ext::SPAN_QUERY, service: service) do |span|
              span.resource = sql
              span.span_type = Tracing::Metadata::Ext::SQL::TYPE
              span.set_tag(Ext::TAG_DB_NAME, db)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_HOST, host)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_PORT, port)
              super # this will pass all args, including the block
            end
          end

          # async_exec(sql) -> PG::Result OR
          # async_exec(sql) {|pg_result| block}
          def async_exec(sql)
            service = Datadog.configuration_for(self, :service_name) || datadog_configuration[:service_name]
            Tracing.trace(Ext::SPAN_QUERY, service: service) do |span|
              span.resource = sql
              span.span_type = Tracing::Metadata::Ext::SQL::TYPE
              span.set_tag(Ext::TAG_DB_NAME, db)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_HOST, host)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_PORT, port)
              super # this will pass all args, including the block
            end
          end

          # async_exec_params(sql, params[, result_format[, type_map]] ) -> PG::Result
          # async_exec_params(sql, params[, result_format[, type_map]] ) {|pg_result| block }
          def async_exec_params(sql, params, result_format = nil, type_map = nil)
            service = Datadog.configuration_for(self, :service_name) || datadog_configuration[:service_name]
            Tracing.trace(Ext::SPAN_QUERY, service: service) do |span|
              span.resource = sql
              span.span_type = Tracing::Metadata::Ext::SQL::TYPE
              span.set_tag(Ext::TAG_DB_NAME, db)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_HOST, host)
              span.set_tag(Tracing::Metadata::Ext::NET::TAG_TARGET_PORT, port)
              super # this will pass all args, including the block
            end
          end

          private

          def datadog_configuration
            Datadog.configuration.tracing[:pg]
          end
        end
      end
    end
  end
end
