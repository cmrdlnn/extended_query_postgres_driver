# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Bind` message which bind the parameters to
      # SQL-statement that prepared by `Parse` message
      # @attr [Array<IO>] streams Array of parameter for binding which is IO
      #   objects (streams), these parameters will be copied directly to the
      #   socket
      class Bind < Base::Message
        # Identifier of `Bind` message
        TYPE = 'B'

        # Creates the `Bind` message
        # @param [String] statement The prepared SQL statement name to
        #   which passed parameters be bound, empty string by default for
        #   unnamed statement
        # @param [String] portal The name of the destination portal (an
        #   empty string selects the unnamed portal)
        # @param [Array<Integer>] format_codes The parameter format
        #   codes, each must presently be zero (text) or one (binary)
        # @param [Array] parameters The values of parameters to bind to
        #   prepared statement. Parameter can be instance of `IO` class to copy
        #   the stream of data directly to socket with `IO.copy_stream` method
        # @param [Array<Integer>] result_format_codes The result-column
        #   format codes, each must presently be zero (text) or one (binary)
        def initialize(
          portal: '',
          statement: '',
          format_codes: [],
          parameters: [],
          result_format_codes: []
        )
          super()
          @streams = []
          write_strings(portal, statement)
          write_format_codes(format_codes)
          write_parameters(parameters)
          write_format_codes(result_format_codes)
        end

        # Sends message to passed socket while copying parameters that are
        # streams
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def send_message(socket)
          return super if @streams.size.zero?
          starts = [0, 0]
          @streams.each do |(ending, tmp_ending, stream)|
            send_part(socket, starts[0], ending, starts[1], tmp_ending)
            starts = ending, tmp_ending
            stream.rewind
            IO.copy_stream(stream, socket)
          end
          send_part(socket, starts[0], @content.size, starts[1], @template.size)
        end

        private

        # Packs part of message into byte sequence and then sends this part to
        # the socket
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        # @param [Integer] start Index of start of content array to be sended
        # @param [Integer] ending Index of end of content array to be sended
        # @param [Integer] tmp_start Index of the start of the pattern with
        #   which the message content will be packed into byte sequence
        # @param [Integer] tmp_ending Index of the end of the pattern with which
        #   the message content will be packed into byte sequence
        def send_part(socket, start, ending, tmp_start, tmp_ending)
          content_part  = @content.slice(start, ending)
          template_part = @template.slice(tmp_start, tmp_ending)
          socket.write(content_part.pack(template_part))
        end

        # Adds the format codes of parameters or results to content of message
        # @param [Array<Integer>] format_codes The parameter format codes
        def write_format_codes(format_codes)
          write_int16(format_codes.size)
          format_codes.each(&method(:write_int16))
        end

        # Adds the parameter values to content of message
        # @param [Array<Integer>] parameters Parameter values
        def write_parameters(parameters)
          write_int16(parameters.size)
          parameters.each(&method(:write_parameter_value))
        end

        # Adds the parameter value to content of message, or add it to streams
        # attribute if parameter is respond to `read` method
        # @param [Array<Integer>] parameters Parameter value
        def write_parameter_value(parameter)
          length = parameter.size
          write_int32(length)
          if parameter.respond_to?(:read)
            @streams.push([@content.size, @template.size, parameter])
            increase_length(length)
          else
            write_bytes(parameter.bytes)
          end
        end
      end
    end
  end
end
