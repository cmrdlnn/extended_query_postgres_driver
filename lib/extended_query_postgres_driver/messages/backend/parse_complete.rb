# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `ParseComplete` message
      # which signals that `Parse` command successfully completed
      class ParseComplete < Base::Message
        # Identifier of `ParseComplete` message
        TYPE = '1'
      end
    end
  end
end
