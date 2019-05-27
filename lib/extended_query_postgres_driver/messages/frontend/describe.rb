# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Describe < FrontendMessage
        TYPE = 'D'

        def initialize(statement_or_portal: 'S', statement_or_portal_name: '')
          super()
          write_string(statement_or_portal)
          write_string(statement_or_portal_name)
        end
      end
    end
  end
end
