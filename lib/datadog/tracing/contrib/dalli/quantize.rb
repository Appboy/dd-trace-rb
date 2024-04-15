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
          INTEGER_ID_REGEX = /\d+/
          # END BRAZE MODIFICATION
          module_function

          def format_command(operation, args)
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
            command = command.gsub(GUID_ID_REGEX, "GUID")
            command = command.gsub(BSON_ID_REGEX, "BSON")
            command = command.gsub(XXHASH_REGEX, "XXHASH")
            command = command.gsub(INTEGER_ID_REGEX, "INTEGER")
            # END BRAZE MODIFICATION
            Core::Utils.truncate(command, Ext::QUANTIZE_MAX_CMD_LENGTH)
          rescue => e
            Datadog.logger.debug("Error sanitizing Dalli operation: #{e}")
            placeholder
          end
        end
      end
    end
  end
end
