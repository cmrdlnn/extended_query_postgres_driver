# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `Startup` that is sent by client when it connect
      # to PostgreSQL server
      class Startup < Base::Message
        # The protocol version number. The most significant 16 bits are the
        # major version number (3 for the protocol described here). The least
        # significant 16 bits are the minor version number (0 for the protocol
        # described here)
        PROTOCOL_VERSION = 196_608

        # Array of arguments names that is passed to `new` class method, these
        # arguments writes to message content according to the same logic
        ARGUMENTS = %i[
          user
          database
          replication
        ].freeze

        # Creates the `Startup` that is sent by client when it connect
        # to PostgreSQL server
        # @param [Hash] args Arguments to create the `Startup` message
        # @option args [String] :user The database user name to connect as
        # @option args [String] :database The database to connect to
        # @option args [String] :replication Used to connect in streaming
        #   replication mode, where a small set of replication commands can be
        #   issued instead of SQL statements. Value can be true, false, or
        #   database, and the default is false
        # @option args [Array<String>] :options Command-line arguments for the
        #   backend. (This is deprecated in favor of setting individual run-time
        #   parameters.) Spaces within this string are considered to separate
        #   arguments, unless escaped with a backslash (\\); write \\\\ to
        #   represent a literal backslash
        def initialize(args)
          @content      = [8, PROTOCOL_VERSION]
          @length_index = 0
          @template     = 'NN'

          ARGUMENTS.each do |arg|
            write_strings(arg.to_s, args[arg]) if args[arg]
          end
          write_options(args[:options]) if args[:options]
          write_byte(0)
        end

        private

        # Adds options to content of message
        # @param [Array<String>] options Command-line arguments
        def write_options(options)
          command_line_arguments = options.map do |option|
            option.gsub(/[ \\]/) { |char| "\\#{char}" }
          end
          write_strings('options', command_line_arguments.join(' '))
        end
      end
    end
  end
end
