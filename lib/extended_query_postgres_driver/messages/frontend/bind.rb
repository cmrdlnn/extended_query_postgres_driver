# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Bind < Base::Message
        TYPE = 'B'

        def initialize(
          portal_name: '',
          statement_name: '',
          format_codes: [],
          parameter_values: [],
          result_column_format_codes: []
        )
          super()
          @streams = []
          write_strings(portal_name, statement_name)
          write_format_codes(format_codes)
          write_parameter_values(parameter_values)
          write_format_codes(result_column_format_codes)
        end

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

        def send_part(socket, start, ending, tmp_start, tmp_ending)
          content_part  = @content.slice(start, ending)
          template_part = @template.slice(tmp_start, tmp_ending)
          socket.write(content_part.pack(template_part))
        end

        def write_format_codes(format_codes)
          write_int16(format_codes.size)
          format_codes.each(&method(:write_int16))
        end

        def write_parameter_values(parameter_values)
          write_int16(parameter_values.size)
          parameter_values.each(&method(:write_parameter_value))
        end

        def write_parameter_value(parameter_value)
          length = parameter_value.size
          write_int32(length)
          if parameter_value.respond_to?(:read)
            @streams.push([@content.size, @template.size, parameter_value])
            increase_length(length)
          else
            write_bytes(parameter_value.bytes)
          end
        end
      end
    end
  end
end
