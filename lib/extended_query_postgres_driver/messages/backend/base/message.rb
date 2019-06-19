# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Namespace of base classes for backend messages
      module Base
        # Base message class for reading and parsing the backend messages
        # from PostgreSQL server
        # @attr [Integer] length Content length in bytes sent at the beginning
        #   of content of any message usually immediately after the message
        #   identifier
        # @attr [String] content Message content
        # @attr [Integer] cursor Pointer to the position from which the message
        #   content will be read
        class Message
          # Creates the backend message class instance for reading and parsing
          # the content of message
          # @param [TCPSocket] socket The TCPSocket instance for interaction
          #   with PostgreSQL server
          def initialize(socket)
            @length  = socket.read(4).unpack('N').first
            @content = socket.read(@length - 4)
            @cursor  = 0
          end

          private

          # Reads one byte of message content from the position pointed by the
          # cursor
          # return [Integer] One byte of the message content starting from the
          #   position pointed by the cursor
          def read_byte
            read('C', 1)
          end

          # Reads a unsigned integer number of sixteen bits from message
          # content from the position pointed by the cursor
          # return [Integer] Unsigned integer number of sixteen bits from
          #   message content from the position pointed by the cursor
          def read_int16
            read('n', 2)
          end

          # Reads a unsigned integer number of thirty two bits from message
          # content from the position pointed by the cursor
          # return [Integer] Unsigned integer number of thirty two bits from
          #   message content from the position pointed by the cursor
          def read_int32
            read('N', 4)
          end

          # Reads a null terminated string from message content from the
          # position pointed by the cursor
          # return [String] Null terminated string from message content from
          #   the position pointed by the cursor
          def read_string
            string = unpack_byteslice('Z*', @content.bytesize)
            @cursor += string.size + 1
            string
          end

          # Reads a bytes from message content from the position pointed by the
          # cursor
          # @param [Integer] count Count of bytes to read
          # return [String] Bytes from message content from the position pointed
          #   by the cursor
          def read_bytes(count)
            result = @content.byteslice(@cursor, count)
            @cursor += count
            result
          end

          # Reads and unpacks some part of message content from the position
          # pointed by the cursor
          # @param [Integer] template Pattern to unpack readed part of message
          #   content
          # @param [Integer] bytes_count Count of bytes to read
          # return [String, Integer] Some parsed part of message content from
          #   the position pointed by the cursor
          def read(template, bytes_count = nil)
            return if @cursor > @content.bytesize
            result = unpack_byteslice(template, bytes_count)
            @cursor += bytes_count
            result
          end

          # Move the cursor to start of message content
          def rewind
            @cursor = 0
          end

          # Reads and unpacks some count of message content bytes from the
          # position pointed by the cursor
          # @param [String] template Pattern to unpack readed part of message
          #   content
          # @param [Integer] bytes_count Count of bytes to read
          # return [String, Integer] Some count of message content bytes from
          #   the position pointed by the cursor
          def unpack_byteslice(template, bytes_count)
            @content.byteslice(@cursor, bytes_count).unpack(template).first
          end
        end
      end
    end
  end
end
