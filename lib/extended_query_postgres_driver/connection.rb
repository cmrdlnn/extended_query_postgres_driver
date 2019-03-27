# frozen_string_literal: true

require 'digest'
require 'socket'

require_relative 'startup_message.rb'

module ExtendedQueryPostgresDriver
  class Status
    def initialize(host, port, user, password, database)
      @socket = TCPSocket.new(host, port)
      @startup_message = StartupMessage.call(user: user, database: database)
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
        when 'E'
          break
        when 'R'
          decoded(payload)
        when 'Z'
          return true
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

    attr_reader :socket, :startup_message, :password, :user
  end
end
