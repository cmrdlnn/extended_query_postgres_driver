# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class Startup < Base::Message
        PROTOCOL_VERSION = 196_608

        ARGUMENTS = %i[
          user
          database
          replication
        ].freeze

        def initialize(args)
          super([8, PROTOCOL_VERSION])
          @length_index = 0
          @template     = 'NN'

          ARGUMENTS.each do |arg|
            write_strings(arg.to_s, args[arg]) if args[arg]
          end
          write_options(args[:options]) if args[:options]
          write_byte(0)
        end

        private

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
