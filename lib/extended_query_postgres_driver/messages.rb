# frozen_string_literal: true

require_relative 'messages/backend'
require_relative 'messages/frontend'

module ExtendedQueryPostgresDriver
  module Messages
    def self.read(socket)
      Backend.read(socket)
    end

    def self.write(socket, type = nil, args = {})
      Frontend.write(socket, type, args)
    end
  end
end
