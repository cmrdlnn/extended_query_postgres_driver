# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Parse < Base::Message
        TYPE = 'P'

        def initialize(query:, statement_name: '', parameter_type_oids: [])
          super()
          write_strings(statement_name, query)
          write_int16(parameter_type_oids.size)
          parameter_type_oids.each(&method(:write_int32))
        end
      end
    end
  end
end
