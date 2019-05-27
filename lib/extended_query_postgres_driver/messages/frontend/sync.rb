# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Sync < FrontendMessage
        TYPE = 'S'
      end
    end
  end
end
