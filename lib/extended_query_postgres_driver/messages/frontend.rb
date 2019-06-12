# frozen_string_literal: true

require_relative 'frontend/base/message'

Dir[File.join(__dir__, 'frontend', '*.rb')].each(&method(:require))

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      MESSAGES = constants.each_with_object(nil => Startup) do |const, memo|
        next if const == :Base
        message_class = const_get(const)
        next unless message_class.const_defined?(:TYPE)
        memo[message_class::TYPE] = message_class
      end.freeze

      def self.write(socket, type, args)
        message = MESSAGES[type].new(args)
        message.send_message(socket)
      end
    end
  end
end
