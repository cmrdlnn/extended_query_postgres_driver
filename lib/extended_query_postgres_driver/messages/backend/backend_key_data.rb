# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `BackendKeyData` message
      # @attr_reader [Integer] process_id The identifier of current PostgreSQL
      #   internal process which handle the client queries
      # @attr_reader [Integer] secret_key The key that allow to close current
      #   active transaction with `CancelRequest` message
      class BackendKeyData < Base::Message
        # Identifier of `BackendKeyData` message
        TYPE = 'K'

        attr_reader :process_id, :secret_key

        # Creates class instance for reading and parsing the content of
        # `BackendKeyData` message
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @process_id = read_int32
          @secret_key = read_int32
        end
      end
    end
  end
end
