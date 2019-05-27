# frozen_string_literal: true

require_relative '../../base/backend_message'

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class DataRow < BackendMessage
        TYPE = 'D'

        def initialize(socket)
          super
          columns_count = read_int16
          @columns = Array.new(columns_count) do
            length = read_int32
            next if length == 4_294_967_295
            read_bytes(length)
          end
        end
      end
    end
  end
end
