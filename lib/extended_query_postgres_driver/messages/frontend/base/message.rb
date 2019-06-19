# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Namespace of base classes for frontend messages
      module Base
        # Base message class for creation, packing and sending frontend messages
        # to PostgreSQL server
        # @attr [Array] content Array of message content parts that will
        #   be packed by `Array#pack` method to binary sequence and then sent to
        #   the PostgreSQL server
        # @attr [Integer] length_index Index of content length in bytes
        #   sent at the beginning of content of any message usually immediately
        #   after the message identifier
        # @attr [String] template A template which pass as parameter to
        #   method `Array#pack` for converting message content to binary
        #   sequence
        class Message
          # Creates message instance and sets initial state of message
          def initialize
            @content      = [self.class::TYPE, 4]
            @length_index = 1
            @template     = 'ZN'
          end

          # Sends message to passed socket
          # @param [TCPSocket] socket The TCPSocket instance for interaction
          #   with PostgreSQL server
          def send_message(socket)
            socket.write(pack)
          end

          private

          # Writes one byte to content of message
          # @param [Integer] value byte which will be written to content of
          #   message
          def write_byte(value)
            write(value, 1, 'C')
          end

          # Writes many byte to content of message one by one
          # @param [Array<Integer>] bytes Bytes which will be written to content
          #   of message one by one
          def write_bytes(bytes)
            bytes.each(&method(:write_byte))
          end

          # Writes a unsigned integer number of thirty two bits to content of
          # message
          # @param [Integer] value Unsigned integer number of thirty two bits
          #   which will be written to content of message
          def write_int32(value)
            write(value, 4, 'N')
          end

          # Writes a unsigned integer number of sixteen to content of message
          # @param [Integer] value Unsigned integer number of sixteen which will
          #   be written to content of message
          def write_int16(value)
            write(value, 2, 'n')
          end

          # Writes a null terminated ASCII string to content of message
          # @param [String] value Null terminated ASCII string which will be
          #   written to content of message
          def write_string(value)
            write(value, value.size + 1, 'Z*')
          end

          # Writes many of null terminated ASCII strings to content of message
          # one by one
          # @param [Array<String>] *strings Many null terminated ASCII strings
          #   which will be written to content of message one by one
          def write_strings(*strings)
            strings.each(&method(:write_string))
          end

          # Packs the contents of the message in a byte sequence
          # @return [String] The contents of the message in a byte sequence
          def pack
            @content.pack(@template)
          end

          # Writes some value `value` of length `length` to content of message
          # and add pattern to `template` attribute for pack this value later
          # @param [Object] value The value that will be added to content of
          #   message
          # @param [Integer] length The length of value
          # @param [String] template The pattern by which the value will be
          #   packed into bytes sequence
          def write(value, length, template)
            increase_length(length)
            @content.push(value)
            @template += template
          end

          # Increase a length value of a content of message
          # @param [Integer] increment The value by which the length of the
          #   message will be increased
          def increase_length(increment)
            @content[@length_index] += increment
          end
        end
      end
    end
  end
end
