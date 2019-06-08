# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      module Base
        class Message < Array
          def initialize(initial_items = [4])
            super
            return unless self.class.const_defined?(:TYPE)
            unshift(self.class::TYPE)
            @length_index = 1
            @template     = 'ZN'
          end

          def pack
            super(@template)
          end

          def write_byte(value)
            write(value, 1, 'C')
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

          private

          def write(value, length, template)
            increase_length(length)
            push(value)
            @template += template
          end

          def increase_length(increment)
            self.[]=(@length_index, self.[](@length_index) + increment)
          end
        end
      end
    end
  end
end
