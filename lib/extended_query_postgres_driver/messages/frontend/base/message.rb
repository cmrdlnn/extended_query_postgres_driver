# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      module Base
        class Message
          def initialize
            @content      = [self.class::TYPE, 4]
            @length_index = 1
            @template     = 'ZN'
          end

          def send_message(socket)
            socket.write(pack)
          end

          private

          def write_byte(value)
            write(value, 1, 'C')
          end

          def write_bytes(bytes)
            bytes.each(&method(:write_byte))
          end

          def write_int32(value)
            write(value, 4, 'N')
          end

          def write_int16(value)
            write(value, 2, 'n')
          end

          def write_string(value)
            write(value, value.size + 1, 'Z*')
          end

          def write_strings(*strings)
            strings.each(&method(:write_string))
          end

          def pack
            @content.pack(@template)
          end

          def write(value, length, template)
            increase_length(length)
            @content.push(value)
            @template += template
          end

          def increase_length(increment)
            @content[@length_index] += increment
          end
        end
      end
    end
  end
end
