# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class BackendKeyData < Base::Message
        TYPE = 'K'

        attr_reader :process_id, :secret_key

        def initialize(socket)
          super
          @process_id = read_int32
          @secret_key = read_int32
        end
      end
    end
  end
end
