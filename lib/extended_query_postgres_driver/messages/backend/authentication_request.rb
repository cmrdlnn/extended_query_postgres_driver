# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of message that request the
      # user authentication
      # @attr_reader [Integer] type Requested authentication type
      # @attr_reader [String] salt Salt to protect hashed password using the
      #   MD5 algorithm
      class AuthenticationRequest < Base::Message
        # Identifier of `AuthenticationRequest` message
        TYPE = 'R'

        attr_reader :type, :salt

        # Creates class instance for reading and parsing the content of message
        # that request the user authentication
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @type = read_int32
          @salt = read_bytes(4) if @type == 5
        end
      end
    end
  end
end
