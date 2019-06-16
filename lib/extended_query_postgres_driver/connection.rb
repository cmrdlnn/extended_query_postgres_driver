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
          password_message(response)
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

    def result
      fields = nil
      results = []

      read_in_loop do |response|
        case response
        when Messages::Backend::RowDescription
          fields = response.fields.map { |field| field[:name].to_sym }
        when Messages::Backend::DataRow
          row = fields.each_with_object({}).with_index do |(field, memo), i|
            memo[field] = response.columns[i]
          end
          results[results.size - 1].push(row)
        when Messages::Backend::ParseComplete
          results.push([])
        when Messages::Backend::CommandComplete
          i = results.size - 1
          next unless results[i].size.zero?
          results.delete_at(i)
        when Messages::Backend::ReadyForQuery
          @transaction_status = response.transaction_status
          break
        end
      end

      results
    end

    def read_in_loop
      loop do
        response = Messages.read(@socket)
        yield response
      end
    end

    def parse(args)
      write('P', args)
    end

    def bind(args = nil)
      write('B', args)
    end

    def describe(args = nil)
      write('D', args)
    end

    def execute(args = nil)
      write('E', args)
    end

    def sync
      write('S')
    end

    private

    def startup
      write(nil, database: config.database, user: config.user)
    end

    def password_message(response)
      write('p', type:     response.type,
                 salt:     response.salt,
                 password: config.password,
                 user:     config.user)
    end

    def write(type, args = nil)
      write_args = [@socket, type]
      write_args.push(args) if args
      Messages.write(*write_args)
    end

    def config
      ExtendedQueryPostgresDriver.config
    end

    def set_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
