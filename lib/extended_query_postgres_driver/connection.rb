# frozen_string_literal: true

require 'digest'
require 'socket'

require_relative 'messages/frontend/startup'
require_relative 'messages/frontend/parse'
require_relative 'messages/frontend/bind'
require_relative 'messages/frontend/execute'
require_relative 'messages/frontend/sync'
require_relative 'messages/backend/parse_complete'
require_relative 'messages/backend/bind_complete'
require_relative 'messages/backend/data_row'

module ExtendedQueryPostgresDriver
  class Status
    ERROR_RESPONSE = 'E'

    AUTHENTICATION_REQUEST = 'R'

    READY_FOR_QUERY = 'Z'

    PARSE = 'P'

    def initialize(host, port, user, password, database)
      @socket = TCPSocket.new(host, port)
      @startup_message = Messages::Frontend::Startup.new(
        user: user,
        database: database
      ).pack
      @password = password
      @user = user
    end

    def self.ready?(host:, port:, user:, password: nil, database: nil)
      new(host, port, user, password, database).start
    end

    def start
      socket.write(startup_message)
      loop do
        char_tag = socket.read(1)
        data = socket.read(4)
        length = data.unpack('L>').first - 4
        payload = socket.read(length)

        case char_tag
        when ERROR_RESPONSE
          break
        when AUTHENTICATION_REQUEST
          decoded(payload)
        when READY_FOR_QUERY
          p 'ready'
          parse
          break
        end
      end
      false
    rescue Errno::ECONNREFUSED
      false
    end

    private

    def decoded(payload)
      # Received **AuthenticationRequest** message
      decoded = payload.unpack('L>').first
      if decoded == 3
        # Cleartext password
        packet = [112, password.size + 5, password].pack('CL>Z*')
        socket.write(packet)
      elsif decoded == 5
        # MD5 password
        salt = payload[4..-1]
        hashed_pass = Digest::MD5.hexdigest([password, user].join)
        encoded_password = 'md5' + Digest::MD5.hexdigest([hashed_pass, salt].join)
        socket.write([112, encoded_password.size + 5, encoded_password].pack('CL>Z*'))
      end
    end

    def parse
      parse = Messages::Frontend::Parse.new(query: 'select * from pg_type;').pack
      bind = Messages::Frontend::Bind.new.pack
      execute = Messages::Frontend::Execute.new.pack
      sync = Messages::Frontend::Sync.new.pack

      socket.write(parse)
      socket.write(bind)
      socket.write(execute)
      socket.write(sync)

      p Messages::Backend::ParseComplete.new(socket)
      p Messages::Backend::BindComplete.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
      p Messages::Backend::DataRow.new(socket)
    end

    attr_reader :socket, :startup_message, :password, :user
  end
end
p ExtendedQueryPostgresDriver::Status.ready?(
  database: 'test_database',
  host: 'localhost',
  port: '5432',
  user: 'test_user',
  password: '123456'
)
