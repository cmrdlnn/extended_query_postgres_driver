# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `ParameterDescription`
      # message which describe the parameter binding by `Bind` command
      # @attr [Integer] params_count Count of binded parameters
      # @attr [Array<Integer>] params Array of parameter type identifiers
      class ParameterDescription < Base::Message
        # Identifier of `ParameterDescription` message
        TYPE = 't'

        # Creates class instance for reading and parsing the content of
        # `ParameterDescription` message which describe the parameter binding by
        # `Bind` command
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @params_count = read_int16
          @params = Array.new(@params_count) { read_int32 }
        end
      end
    end
  end
end
