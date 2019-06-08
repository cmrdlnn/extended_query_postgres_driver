# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class AuthenticationRequest < Base::Message
        TYPE = 'R'

        attr_reader :type, :salt

        def initialize(socket)
          super
          @type = read_int32
          @salt = read_bytes(4) if @type == 5
        end
      end
    end
  end
end
