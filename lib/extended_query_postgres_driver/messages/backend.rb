# frozen_string_literal: true

require_relative 'backend/base/message'

Dir[File.join(__dir__, 'backend', '*.rb')].each(&method(:require))

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # The associative array in which keys are identifiers of frontend messages
      # and values are the classes for their creation
      MESSAGES = constants.each_with_object({}) do |const, memo|
        next if const == :Base
        message_class = const_get(const)
        memo[message_class::TYPE] = message_class
      end.freeze

      # Reads and decodes the identifier of backend message and creates message
      # class instance using this identifier then reads and parse the main
      # content of message
      # @param [TCPSocket] socket The socket connected to the PostgreSQL server
      #   from which message will be read
      def self.read(socket)
        type = socket.read(1).unpack('Z').first
        MESSAGES[type].new(socket)
      end
    end
  end
end
