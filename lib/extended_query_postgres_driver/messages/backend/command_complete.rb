# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `CommandComplete` message
      # which signals that some SQL query was successfully complete
      # @attr_reader [String] command_tag The command tag. This is usually a
      #   single word that identifies which SQL command was completed
      class CommandComplete < Base::Message
        # Identifier of `CommandComplete` message
        TYPE = 'C'

        # Creates class instance for reading and parsing the content of
        # `CommandComplete` message which signals that some SQL query was
        # successfully complete
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          @command_tag = read_string
        end
      end
    end
  end
end
