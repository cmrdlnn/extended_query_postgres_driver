# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Describe` message to describe some portal or
      # SQL-statement
      class Describe < Base::Message
        # Identifier of `Describe` message
        TYPE = 'D'

        # Creates `Describe` message to describe some portal or SQL-statement
        # @param [String] statement_or_portal 'S' to describe a prepared
        #   statement; or 'P' to describe a portal
        # @param [String] statement_or_portal_name The name of the
        #   prepared statement or portal to describe (an empty string selects
        #   the unnamed prepared statement or portal)
        def initialize(statement_or_portal: 'S', statement_or_portal_name: '')
          super()
          write_byte(statement_or_portal.ord)
          write_string(statement_or_portal_name)
        end
      end
    end
  end
end
