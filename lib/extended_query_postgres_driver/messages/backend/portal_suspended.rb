# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class PortalSuspended < Base::Message
        TYPE = 's'
      end
    end
  end
end
