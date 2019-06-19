# frozen_string_literal: true

require_relative 'frontend/base/message'

Dir[File.join(__dir__, 'frontend', '*.rb')].each(&method(:require))

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # The associative array in which keys are identifiers of backend messages
      # and values are the classes for their creation
      MESSAGES = constants.each_with_object(nil => Startup) do |const, memo|
        next if const == :Base
        message_class = const_get(const)
        next unless message_class.const_defined?(:TYPE)
        memo[message_class::TYPE] = message_class
      end.freeze

      # Creates new message by identifier and message instance initializing
      # arguments and write it to passed socket
      # @param [TCPSocket] socket The socket connected to the PostgreSQL server
      #   to which messages will be written
      # @param [String] type Message identifier by which the class of the
      #   message being created will be determined
      # @param [Hash] args Arguments used to create new message instance
      def self.write(socket, type = nil, args = {})
        message = MESSAGES[type].new(args)
        message.send_message(socket)
      end
    end
  end
end
