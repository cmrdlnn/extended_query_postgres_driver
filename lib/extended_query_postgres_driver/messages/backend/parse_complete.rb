# frozen_string_literal: true

require_relative '../../base/backend_message'

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ParseComplete < BackendMessage
        TYPE = '1'
      end
    end
  end
end
