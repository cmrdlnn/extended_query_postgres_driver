# frozen_string_literal: true

require_relative 'backend/base/message'

Dir[File.join(__dir__, 'backend', '*.rb')].each(&method(:require))

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      MESSAGES = constants.each_with_object({}) do |const, memo|
        next if const == :Base
        message_class = const_get(const)
        memo[message_class::TYPE] = message_class
      end.freeze

      def self.read(socket)
        type = socket.read(1).unpack('Z').first
        p type
        MESSAGES[type].new(socket)
      end
    end
  end
end
