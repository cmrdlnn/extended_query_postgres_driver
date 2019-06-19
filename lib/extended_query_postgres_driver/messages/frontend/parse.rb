# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Parse` message to prepare SQL-statement to
      # execute later
      class Parse < Base::Message
        # Identifier of `Parse` message
        TYPE = 'P'

        # Creates `Parse` to prepare SQL-statement to execute later
        # @param [String] query The SQL-statement to be prepared
        # @param [String] statement The name of statement to be prepared
        # @param [Array<Integer>] oids The identifiers of statement parameters
        #   types
        def initialize(query:, statement: '', oids: [])
          super()
          write_strings(statement, query)
          write_int16(oids.size)
          oids.each(&method(:write_int32))
        end
      end
    end
  end
end
