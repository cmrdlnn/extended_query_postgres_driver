# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `NoticeResponse` message
      # @attr [Integer] field_type A code identifying the field type
      # @attr [String] field_value The field value
      class NoticeResponse < Base::Message
        # Identifier of `NoticeResponse` message
        TYPE = 'N'

        # Creates class instance for reading and parsing the content of
        # `NoticeResponse` message
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @field_type = read_byte
          @field_value = read_string
        end
      end
    end
  end
end
