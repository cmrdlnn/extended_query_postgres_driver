# frozen_string_literal: true

require 'socket'

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # Class for connection and messaging with PostgreSQL server through TCP socket
  # @attr_reader [TCPSocket] socket The TCPSocket instance for interaction with
  #   PostgreSQL server
  # @attr [Integer] process_id The identifier of current PostgreSQL
  #   internal process which handle the client queries
  # @attr [Integer] secret_key The key that allow to close current active
  #   transaction with `CancelRequest` message
  # @attr [Integer] transaction_status Current backend transaction status
  #   indicator. Possible values are 'I' if idle (not in a transaction block);
  #   'T' if in a transaction block; or 'E' if in a failed transaction block
  #   (queries will be rejected until block is ended)
  class Connection
    # Creates TCPSocket instance with host and port which stored in library
    # configuration object and then connect to PostgreSQL server
    def initialize
      @socket = TCPSocket.new(config.host, config.port)
      connect
    end

    # The TCPSocket instance for interaction with PostgreSQL server
    attr_reader :socket

    # Sends startup and authentication messages to PostgreSQL server and receive
    # messages with server information that sets to class instance attributes
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

    # Receives information in infinity loop from PostgreSQL server about results
    # of queries processing
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
        when Messages::Backend::BindComplete
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

    # Reads the PostgreSQL server messages from socket and process they in the
    # infinity loop
    # @yieldparam [Messages::Backend::Base::Message] response The backend
    #   processed message class instance which sends by PostgreSQL server to
    #   client
    def read_in_loop
      loop do
        response = Messages::Backend.read(@socket)
        yield response
      end
    end

    # Creates and then sends `Parse` message to PostgreSQL server to prepare
    # SQL-statement to execute later
    # @param [Hash] args Arguments for `Parse` message creation
    # @option args [String] :query The SQL statement to be prepared
    # @option args [String] :statement The name of statement to be prepared
    # @option args [Array<Integer>] :oids The identifiers of parameters types
    def parse(args)
      write('P', args)
    end

    # Creates and then send `Bind` message to PostgreSQL server. This message
    # bind the parameters to SQL-statement that prepared by `Parse` message
    # @param [Hash] args Arguments for `Bind` message creation
    # @option args [String] :statement The prepared SQL statement name to which
    #   passed parameters be bound, empty string by default for unnamed
    #   statement
    # @option args [String] :portal The name of the destination portal (an empty
    #   string selects the unnamed portal)
    # @option args [Array<Integer>] :format_codes The parameter format codes,
    #   each must presently be zero (text) or one (binary)
    # @option args [Array] :parameters The values of parameters to bind to
    #   prepared statement. Parameter can be instance of `IO` class to copy the
    #   stream of data directly to socket with `IO.copy_stream` method
    # @option args [Array<Integer>] :result_format_codes The result-column
    #   format codes, each must presently be zero (text) or one (binary)
    def bind(args = nil)
      write('B', args)
    end

    # Creates and then sends `Describe` message to PostgreSQL server to describe
    # some portal or SQL-statement
    # @param [Hash] args Arguments for `Describe` message creation
    # @option args [String] :statement_or_portal 'S' to describe a prepared
    #   statement; or 'P' to describe a portal
    # @option args [String] :statement_or_portal_name The name of the prepared
    #   statement or portal to describe (an empty string selects the unnamed
    #   prepared statement or portal)
    def describe(args = nil)
      write('D', args)
    end

    # Creates and then sends `Execute` message to PostgreSQL server to execute
    # the prepared and binded SQL-statement
    # @param [Hash] args Arguments for `Execute` message creation
    # @option args [String] :portal The name of the portal to execute (an empty
    #   string selects the unnamed portal)
    # @option args [String] :rows_number Maximum number of rows to return, if
    #   portal contains a query that returns rows (ignored otherwise). Zero
    #   denotes “no limit”
    def execute(args = nil)
      write('E', args)
    end

    # Creates and then sends `Sync` message to PostgreSQL server. It signals the
    # ending of client commands and that the server can close the current
    # transaction
    def sync
      write('S')
    end

    # Close the connection to PostgreSQL server
    def close
      @socket.close
    end

    private

    # Creates and then sends the startup message to PostgreSQL server
    def startup
      write(nil, database: config.database, user: config.user)
    end

    # Creates and then sends the authenticate message
    # @param [Messages::Backend::AuthenticationRequest] authentication_request
    #   instance of `AuthenticationRequest` backend message that contain the
    #   type of authentication
    def password_message(authentication_request)
      write('p', type:     authentication_request.type,
                 salt:     authentication_request.salt,
                 password: config.password,
                 user:     config.user)
    end

    # Looking for message class by identifier then creates it and send to
    # PostgreSQL server
    # @param [String] type The message type identifier
    # @param [Hash] args Arguments to create the found message
    def write(type, args = nil)
      write_args = [@socket, type]
      write_args.push(args) if args
      Messages::Frontend.write(*write_args)
    end

    # Returns configuration object with database connection settings
    # @return [Config] Configuration object with database connection settings
    def config
      ExtendedQueryPostgresDriver.config
    end

    # Sets an instance variables with passed name and value
    # @param [String] name Name of instance variable
    # @param [String] value Value of instance variable
    def set_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
