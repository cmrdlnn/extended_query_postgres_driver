# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class DataRow < Base::Message
        TYPE = 'D'

        attr_reader :columns

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
