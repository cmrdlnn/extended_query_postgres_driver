# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class RowDescription < Base::Message
        TYPE = 'T'

        attr_reader :fields

        def initialize(socket)
          super
          @fields_count = read_int16
          @fields = Array.new(@fields_count) do
            {
              name: read_string,
              table_id: read_int32,
              column_number: read_int16,
              data_type_oid: read_int32,
              data_type_size: read_int16,
              data_type_modifier: read_int32,
              format_code: read_int16
            }
          end
        end
      end
    end
  end
end
