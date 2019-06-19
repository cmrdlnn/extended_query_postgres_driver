# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `NoData` message
      # which signals that some of the executed SQL query has no data as a
      # result
      class NoData < Base::Message
        # Identifier of `NoData` message
        TYPE = 'n'
      end
    end
  end
end
