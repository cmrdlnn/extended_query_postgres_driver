# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  class BackendMessage
    def initialize(socket)
      @type, @length = socket.read(5).unpack('ZN')
      check_type!
      @content = socket.read(@length - 4)
      check_postgresql_error!
      @cursor = 0
    end

    def unpack(template = nil)
      @content.unpack(template)
    end

    def read_byte
      read('C', 1)
    end

    def read_int16
      read('n', 2)
    end

    def read_int32
      read('N', 4)
    end

    def read_bytes(count)
      result = @content.byteslice(@cursor, count)
      @cursor += count
      result
    end

    def read(template, bytes_count = nil)
      return if @cursor > @content.bytesize
      result = @content.byteslice(@cursor, bytes_count).unpack(template).first
      @cursor += bytes_count
      result
    end

    def rewind
      @cursor = 0
    end

    private

    def check_type!
      return if @type == self.class::TYPE
      raise "Invalid message type #{@type} received for class " \
            "#{self.class.to_s.split('::').last} and type #{self.class::TYPE}"
    end

    ERROR_FIELDS = {
      'H' => 'Hint',
      'M' => 'Message',
      'S' => 'Type'
    }.freeze

    def check_postgresql_error!
      return unless @type == 'E'
      message = @content.split(0.chr).each_with_object([]) do |part, memo|
        field = ERROR_FIELDS[part[0]]
        memo << "#{field}: #{part[1..part.size]}" if field
      end
      raise message.join(', ')
    end
  end
end
