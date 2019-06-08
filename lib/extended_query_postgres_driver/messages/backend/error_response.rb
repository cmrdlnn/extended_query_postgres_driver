# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ErrorResponse < Base::Message
        TYPE = 'E'

        ERROR_FIELDS = {
          'H' => 'hint',
          'M' => 'message',
          'S' => 'Type'
        }.freeze

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
