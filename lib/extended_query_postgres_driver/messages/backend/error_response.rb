# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `ErrorResponse` message
      # which singals about some error that occurred during the message exchange
      # @attr_reader [String] columns Columns of returned row
      class ErrorResponse < Base::Message
        # Identifier of `ErrorResponse` message
        TYPE = 'E'

        # Map of message parts and their description
        ERROR_FIELDS = {
          'H' => 'hint',
          'M' => 'message',
          'S' => 'Type'
        }.freeze

        # Creates class instance for reading and parsing the content of
        # `ErrorResponse` message which singals about some error that
        # occurred during the message exchange
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        # @raise [RuntimeError] When PostreSQL send `ErrorResponse` message
        def initialize(socket)
          super
          message = @content.split(0.chr).each_with_object([]) do |part, memo|
            field = ERROR_FIELDS[part[0]]
            memo << "#{field}: #{part[1..part.size]}" if field
          end
          raise message.join(', ')
        end
      end
    end
  end
end
