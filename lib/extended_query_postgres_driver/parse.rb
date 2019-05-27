# frozen_string_literal: true

module ExtendedQueryPostgresDriver
  class Parse
    TYPE = 'P'

    def initialize(query, statement_name = '', parameter_type_oids = [])
      @buffer = WritableBuffer.new(TYPE)
      @buffer.write_string(statement_name)
      @buffer.write_string(query)
      parameter_type_oids.each { |oid| @buffer.write_int16(oid) }
    end

    def pack
      @buffer.pack
    end
  end
end
