# frozen_string_literal: true

require 'socket'

module ExtendedQueryPostgresDriver
  class Connection
    def initialize
      @socket = TCPSocket.new(config.host, config.port)
      connect
    end

    attr_reader :socket

    def connect
      startup
      read_in_loop do |response|
        case response
        when Messages::Backend::AuthenticationRequest
          next if response.type.zero?
          authenticate(response)
        when Messages::Backend::ParameterStatus
          set_variable(response.name, response.value)
        when Messages::Backend::BackendKeyData
          @process_id = response.process_id
          @secret_key = response.secret_key
        when Messages::Backend::ReadyForQuery
          @transaction_status = response.transaction_status
          break
        end
      end
    end

    private

    def read_in_loop
      loop do
        response = Messages.read(@socket)
        yield response
      end
    end

    def startup
      Messages.write(@socket, nil, database: config.database, user: config.user)
    end

    def authenticate(response)
      Messages.write(@socket, 'p', type: response.type,
                                   salt: response.salt,
                                   password: config.password,
                                   user: config.user)
    end

    def config
      ExtendedQueryPostgresDriver.config
    end

    def set_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
