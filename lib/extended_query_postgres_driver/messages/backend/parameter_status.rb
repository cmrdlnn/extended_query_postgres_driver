# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class ParameterStatus < Base::Message
        TYPE = 'S'

        attr_reader :name, :value

        def initialize(socket)
          super
          @name  = read_string
          @value = read_string
        end
      end
    end
  end
end
