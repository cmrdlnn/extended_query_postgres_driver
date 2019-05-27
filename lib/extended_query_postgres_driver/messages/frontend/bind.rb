# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Bind < FrontendMessage
        TYPE = 'B'

        def initialize(
          portal_name: '',
          statement_name: '',
          format_codes: [],
          parameter_values: [],
          result_column_format_codes: []
        )
          super()
          write_strings(portal_name, statement_name)
          write_format_codes(format_codes)
          write_parameter_values(parameter_values)
          write_format_codes(result_column_format_codes)
        end

        private

        def write_format_codes(format_codes)
          write_int16(format_codes.size)
          format_codes.each(&method(:write_int16))
        end

        def write_parameter_values(parameter_values)
          write_int16(parameter_values.size)
          parameter_values.each do |parameter_value|
            write_int32(parameter_value.size)
            write_string(parameter_value)
          end
        end
      end
    end
  end
end
