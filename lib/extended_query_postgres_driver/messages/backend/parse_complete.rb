# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ParseComplete < Base::Message
        TYPE = '1'
      end
    end
  end
end
