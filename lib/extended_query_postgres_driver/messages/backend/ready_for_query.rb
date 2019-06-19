# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `ReadyForQuery` message
      # which signals that server ready to execute new query
      # @attr_reader [Integer] transaction_status Current backend transaction
      #   status indicator. Possible values are 'I' if idle (not in a
      #   transaction block); 'T' if in a transaction block; or 'E' if in a
      #   failed transaction block (queries will be rejected until block is
      #   ended)
      class ReadyForQuery < Base::Message
        # Identifier of `ReadyForQuery` message
        TYPE = 'Z'

        attr_reader :transaction_status

        # Creates class instance for reading and parsing the content of
        # `ReadyForQuery` message which signals that server ready to execute new
        # query
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @transaction_status = read_byte
        end
      end
    end
  end
end
