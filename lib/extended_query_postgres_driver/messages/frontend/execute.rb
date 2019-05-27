# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Execute < FrontendMessage
        TYPE = 'E'

        def initialize(portal_name: '', rows_number: 0)
          super()
          write_string(portal_name)
          write_int32(rows_number)
        end
      end
    end
  end
end
