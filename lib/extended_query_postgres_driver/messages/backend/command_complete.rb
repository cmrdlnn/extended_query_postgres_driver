# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  module Messages
    module Backend
      class CommandComplete < Base::Message
        TYPE = 'C'

        def initialize(socket)
          super
          @command_tag = read_string
        end
      end
    end
  end
end
