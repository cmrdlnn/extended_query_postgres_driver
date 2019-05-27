# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  class StartupMessage
    # Начальное состояние
    MESSAGE = [8, 196_608].freeze

    # Шаблон метода Array#pack для кодирования первых двух частей стартового
    # сообщения - длинны сообщения в байтах и версии протокола
    LENGTH_AND_VERSION_TEMPLATE = 'NN'

    PARAMETER_PAIRS_TEMPLATE = 'Z*'

    NULL_BYTE_TEMPLATE = 'C'

    PARAMETERS = %i[
      database
      user
    ].freeze

    def self.call(parameters)
      new(parameters).call
    end

    def initialize(parameters)
      @parameters = parameters
      @message = MESSAGE.dup
      @pack_string = LENGTH_AND_VERSION_TEMPLATE.dup
    end

    def call
      PARAMETERS.each do |parameter|
        next unless @parameters.key?(parameter)
        write(parameter.to_s, parameter.size, PARAMETER_PAIRS_TEMPLATE)
        write(@parameters[parameter], @parameters[parameter].size, PARAMETER_PAIRS_TEMPLATE)
      end

      write(0, 0, NULL_BYTE_TEMPLATE)
      p @message
      @message.pack(@pack_string)
    end

    def write(value, size, template)
      @message << value
      @message[0] += size + 1
      @pack_string << template
    end
  end
end
