# frozen_string_literal: true

require 'digest'
require 'socket'

require_relative 'startup_message'

module ExtendedQueryPostgresDriver
  class Status
    def self.ready?(host:, port:, user:, password: nil, database: nil)
      socket = TCPSocket.new(host, port)
      startup_message = StartupMessage.call(user: user, database: database)
      socket.write(startup_message)

      while true
        char_tag = socket.read(1)
        data = socket.read(4)
        length = data.unpack('L>').first - 4
        payload = socket.read(length)

        case char_tag
        when 'E'
          # Received **ErrorResponse**
          break
        when 'R'
          # Received **AuthenticationRequest** message
          decoded = payload.unpack('L>').first

          case decoded
          when 3
            # Cleartext password
            packet = [112, password.size + 5, password].pack('CL>Z*')
            socket.write(packet)
          when 5
            # MD5 password
            salt = payload[4..-1]
            hashed_pass = Digest::MD5.hexdigest([password, user].join)
            encoded_password = 'md5' + Digest::MD5.hexdigest([hashed_pass, salt].join)
            socket.write([112, encoded_password.size + 5, encoded_password].pack('CL>Z*'))
          end
        when 'Z'
          # Received **Ready for query** message
          return true
        end
      end

      false
    rescue Errno::ECONNREFUSED
      false
    end
  end
end
