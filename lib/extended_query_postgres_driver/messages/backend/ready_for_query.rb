# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ReadyForQuery < Base::Message
        TYPE = 'Z'

        attr_reader :transaction_status

        def initialize(socket)
          super
          @transaction_status = read_byte
        end
      end
    end
  end
end
