# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Sync`. It signals the ending of client commands
      # and that the server can close the current transaction
      class Sync < Base::Message
        # Identifier of `Sync` message
        TYPE = 'S'

        # Creates the `Sync`. It signals the ending of client commands
        # and that the server can close the current transaction
        # @param [Hash] _ Non-used arguments
        def initialize(_)
          super()
        end
      end
    end
  end
end
