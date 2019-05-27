# frozen_string_literal: true

require_relative '../../base/backend_message'

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class BindComplete < BackendMessage
        TYPE = '2'
      end
    end
  end
end
