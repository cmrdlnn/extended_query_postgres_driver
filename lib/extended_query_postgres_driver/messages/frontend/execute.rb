# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Execute` message to execute the prepared and
      # binded SQL-statement
      class Execute < Base::Message
        # Identifier of `Execute` message
        TYPE = 'E'

        # Creates `Execute` to execute the prepared and binded SQL-statement
        # @param [String] portal The name of the portal to execute (an empty
        #   string selects the unnamed portal)
        # @param [String] rows_number Maximum number of rows to return, if
        #   portal contains a query that returns rows (ignored otherwise). Zero
        #   denotes “no limit”
        def initialize(portal: '', rows_number: 0)
          super()
          write_string(portal)
          write_int32(rows_number)
        end
      end
    end
  end
end
