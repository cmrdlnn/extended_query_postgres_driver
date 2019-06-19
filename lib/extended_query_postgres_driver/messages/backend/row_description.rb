# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `RowDescription` message
      # which describe the result row structure
      # @attr [Integer] fields_count Count of described fields
      # @attr_reader [Array<Hash>] fields Fields description
      class RowDescription < Base::Message
        # Identifier of `RowDescription` message
        TYPE = 'T'

        attr_reader :fields

        # Creates class instance for reading and parsing the content of
        # `RowDescription` message which describe the result row structure
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @fields_count = read_int16
          @fields = Array.new(@fields_count) do
            {
              name: read_string,
              table_id: read_int32,
              column_number: read_int16,
              data_type_oid: read_int32,
              data_type_size: read_int16,
              data_type_modifier: read_int32,
              format_code: read_int16
            }
          end
        end
      end
    end
  end
end
