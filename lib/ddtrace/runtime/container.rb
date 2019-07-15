require 'ddtrace/ext/runtime'

module Datadog
  module Runtime
    # For container environments
    module Container
      UUID_PATTERN = '[0-9a-f]{8}[-_][0-9a-f]{4}[-_][0-9a-f]{4}[-_][0-9a-f]{4}[-_][0-9a-f]{12}'.freeze
      CONTAINER_PATTERN = '[0-9a-f]{64}'.freeze

      LINE_REGEX = /^(\d+):([^:]*):(.+)$/.freeze
      POD_REGEX = /pod(#{UUID_PATTERN})(?:.slice)?$/
      CONTAINER_REGEX = /(#{UUID_PATTERN}|#{CONTAINER_PATTERN})(?:.scope)?$/

      Descriptor = Struct.new(
        :id,
        :groups,
        :path,
        :controllers,
        :container_id,
        :pod_id
      )

      def self.parse_line(line)
        id, groups, path = line.scan(LINE_REGEX).first
        Descriptor.new(id, groups, path).tap do |descriptor|
          unless groups.nil?
            controllers = groups.split(',')
            descriptor.controllers = controllers if controllers
          end

          unless path.nil?
            parts = path.split('/')

            container_id = parts.pop[CONTAINER_REGEX]
            descriptor.container_id = container_id unless container_id.nil?

            pod_id = parts.pop[POD_REGEX]
            descriptor.pod_id = pod_id unless pod_id.nil?
          end
        end
      end
    end
  end
end
