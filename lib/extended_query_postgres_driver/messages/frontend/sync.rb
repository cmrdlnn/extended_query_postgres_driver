# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Sync < Base::Message
        TYPE = 'S'

        def initialize(_)
          super()
        end
      end
    end
  end
end
