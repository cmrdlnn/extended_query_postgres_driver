# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class BindComplete < Base::Message
        TYPE = '2'
      end
    end
  end
end
