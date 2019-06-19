# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `PortalSuspended` message
      # which signals about ending of result rows
      class PortalSuspended < Base::Message
        # Identifier of `PortalSuspended` message
        TYPE = 's'
      end
    end
  end
end
