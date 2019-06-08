# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ParameterDescription < Base::Message
        TYPE = 't'

        def initialize(socket)
          super
          @params_count = read_int16
          @params = Array.new(@params_count) { read_int32 }
        end
      end
    end
  end
end
