# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `ParameterStatus`
      # message which describe some the PostgreSQL server settings
      # @attr_reader [String] name The name of the run-time parameter being
      #   reported
      # @attr_reader [String] value The current value of the parameter
      class ParameterStatus < Base::Message
        # Identifier of `ParameterStatus` message
        TYPE = 'S'

        attr_reader :name, :value

        # Creates class instance for reading and parsing the content of
        # `ParameterStatus` message which describe some the PostgreSQL
        # server settings
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @name  = read_string
          @value = read_string
        end
      end
    end
  end
end
