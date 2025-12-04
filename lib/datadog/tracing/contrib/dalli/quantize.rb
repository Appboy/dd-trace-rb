# frozen_string_literal: true

require_relative 'ext'

module Datadog
  module Tracing
    module Contrib
      module Dalli
        # Quantize contains dalli-specic quantization tools.
        module Quantize
          # BEGIN BRAZE MODIFICATION
          GUID_ID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
          BSON_ID_REGEX = /[0-9a-f]{24}/i
          XXHASH_REGEX = /[0-9a-f]{16}/
          INTEGER_ID_REGEX = /\d\d+/ # 2 or more digits (to exclude things like ":v2")
          # END BRAZE MODIFICATION
          module_function

          def format_command(operation, args, truncate = true)
            placeholder = "#{operation} BLOB (OMITTED)"
            # BEGIN BRAZE MODIFICATION
            if operation == :send_multiget
              command = [operation, *args].join(' ').strip
            else
              # all operations except multiget have the key as the first arg
              command = [operation, args[0]].join(' ').strip
            end
            # END BRAZE MODIFICATION

            command = Core::Utils.utf8_encode(command, binary: true, placeholder: placeholder)
            # BEGIN BRAZE MODIFICATION
            quantized_command = command.gsub(GUID_ID_REGEX, "GUID")
            quantized_command = quantized_command.gsub(BSON_ID_REGEX, "BSON")
            quantized_command = quantized_command.gsub(XXHASH_REGEX, "XXHASH")
            quantized_command = quantized_command.gsub(INTEGER_ID_REGEX, "INTEGER")

            [
              Core::Utils.truncate(command, Ext::QUANTIZE_MAX_CMD_LENGTH),
              Core::Utils.truncate(quantized_command, Ext::QUANTIZE_MAX_CMD_LENGTH),
              command.length,
            ]
            # END BRAZE MODIFICATION
          rescue => e
            Datadog.logger.debug("Error sanitizing Dalli operation: #{e}")
            placeholder
          end
        end
      end
    end
  end
end
