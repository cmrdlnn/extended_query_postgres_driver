# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `BindComplete` message
      # which signals that `Bind` command successfully completed
      class BindComplete < Base::Message
        # Identifier of `BackendKeyData` message
        TYPE = '2'
      end
    end
  end
end
