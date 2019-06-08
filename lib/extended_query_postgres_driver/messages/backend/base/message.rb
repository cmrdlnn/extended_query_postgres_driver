# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      module Base
        class Message
          def initialize(socket)
            @length  = socket.read(4).unpack('N').first
            @content = socket.read(@length - 4)
            @cursor  = 0
          end

          def unpack(template = nil)
            @content.unpack(template)
          end

          def read_byte
            read('C', 1)
          end

          def read_int16
            read('n', 2)
          end

          def read_int32
            read('N', 4)
          end

          def read_string
            string = unpack_byteslice('Z*', @content.bytesize)
            @cursor += string.size + 1
            string
          end

          def read_bytes(count)
            result = @content.byteslice(@cursor, count)
            @cursor += count
            result
          end

          def read(template, bytes_count = nil)
            return if @cursor > @content.bytesize
            result = unpack_byteslice(template, bytes_count)
            @cursor += bytes_count
            result
          end

          def rewind
            @cursor = 0
          end

          private

          def unpack_byteslice(template, bytes_count)
            @content.byteslice(@cursor, bytes_count).unpack(template).first
          end
        end
      end
    end
  end
end
