# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class NoData < Base::Message
        TYPE = 'n'
      end
    end
  end
end
