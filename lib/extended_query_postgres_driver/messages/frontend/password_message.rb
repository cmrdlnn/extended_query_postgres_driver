# frozen_string_literal: true

require 'digest'

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle frontend messages
    module Frontend
      # Class that creates the `PasswordMessage` message to authenticate user on
      # PostgreSQL server
      class PasswordMessage < Base::Message
        # Identifier of `PasswordMessage` message
        TYPE = 'p'

        # Creates `PasswordMessage` message to authenticate user on PostgreSQL
        # server
        # @param [String] password The password to authenticate user on
        #   PostgreSQL server
        # @param [String] salt The salt to protect hashed password using the MD5
        #   algorithm
        # @param [Integer] type Authentication type
        # @param [String] user The name of user to being authenticated
        # @raise [RuntimeError] When authentication type is unsupported by the
        #   library
        def initialize(password:, salt: nil, type:, user: nil)
          super()
          case type
          when 3
            write_string(password)
          when 5
            write_string(md5_password(user, password, salt))
          else
            unsupported_type!(type)
          end
        end

        private

        # Hashes the user password using the MD5 algorithm
        # @param [String] user The name of user to being authenticated
        # @param [String] password The password to authenticate user on
        #   PostgreSQL server
        # @param [String] salt The salt to protect hashed password using the MD5
        #   algorithm
        # @return [String] Hashed password
        def md5_password(user, password, salt)
          hashed_password = Digest::MD5.hexdigest("#{password}#{user}")
          'md5' + Digest::MD5.hexdigest("#{hashed_password}#{salt}")
        end

        # Map of PostgreSQL authentication types and these descriptions
        AUTHENTICATION_TYPES = {
          2  => 'Kerberos V5',
          6  => 'SCM credentials',
          7  => 'GSSAPI',
          8  => 'GSSAPI or SSPI',
          9  => 'SSPI',
          10 => 'SASL',
          11 => 'SASL challenge',
          12 => 'SASL final'
        }.freeze

        # Message text that signals that the server is requesting an
        # authentication type that is not supported by the library
        MESSAGE = 'Unsupported authentication type'

        # @raise [RuntimeError] When authentication type is unsupported by the
        #   library
        def unsupported_type!(type)
          raise MESSAGE unless AUTHENTICATION_TYPES.key?(type)
          raise "#{MESSAGE} - #{AUTHENTICATION_TYPES[type]}"
        end
      end
    end
  end
end
