# frozen_string_literal: true

require 'digest'

module ExtendedQueryPostgresDriver
  module Messages
    module Frontend
      class PasswordMessage < Base::Message
        TYPE = 'p'

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

        def md5_password(user, password, salt)
          hashed_password = Digest::MD5.hexdigest("#{password}#{user}")
          'md5' + Digest::MD5.hexdigest("#{hashed_password}#{salt}")
        end

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

        MESSAGE = 'Unsupported authentication type'

        def unsupported_type!(type)
          raise MESSAGE unless AUTHENTICATION_TYPES.key?(type)
          raise "#{MESSAGE} - #{AUTHENTICATION_TYPES[type]}"
        end
      end
    end
  end
end
