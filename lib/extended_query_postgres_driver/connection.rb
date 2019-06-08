# frozen_string_literal: true

require 'socket'

module ExtendedQueryPostgresDriver
  class Connection
    def initialize
      @socket = TCPSocket.new('localhost', '5432')
      connect
    end

    attr_reader :socket

    def connect
      Messages.write(@socket, nil, database: 'test_database', user: 'test_user')
      loop do
        response = Messages.read(@socket)
        case response
        when Messages::Backend::AuthenticationRequest
          next if response.type.zero?
          Messages.write(@socket, 'p', type: response.type, salt: response.salt, password: '123456', user: 'test_user')
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

    def test_query
      Messages.write(@socket, 'P', query: 'select * from pg_type limit 1;')
      Messages.write(@socket, 'B')
      Messages.write(@socket, 'D')
      Messages.write(@socket, 'E')
      Messages.write(@socket, 'S')

      fields = []
      result = []

      loop do
        response = Messages.read(@socket)
        p response
        case response
        when Messages::Backend::RowDescription
          fields = response.fields.map { |field| field[:name].to_sym }
        when Messages::Backend::DataRow
          row = fields.each_with_object({}).with_index do |(field, memo), i|
            memo[field] = response.columns[i]
          end
          result.push(row)
        when Messages::Backend::ReadyForQuery
          @transaction_status = response.transaction_status
          break
        end
      end

      result
    end

    private

    def set_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
