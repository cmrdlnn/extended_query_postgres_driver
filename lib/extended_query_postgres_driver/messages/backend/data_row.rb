# frozen_string_literal: true

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  # The namespace containing the functionality to handle frontend and backend
  # messages
  module Messages
    # The namespace containing the functionality to handle backend messages
    module Backend
      # Class for reading and parsing the content of `DataRow` message
      # which return the row of result of some SQL query
      # @attr_reader [Array<String>] columns Columns of returned row
      class DataRow < Base::Message
        # Identifier of `DataRow` message
        TYPE = 'D'

        attr_reader :columns

        # Creates class instance for reading and parsing the content of
        # `DataRow` message message which return the row of result of some SQL
        # query
        # @param [TCPSocket] socket The TCPSocket instance for interaction
        #   with PostgreSQL server
        def initialize(socket)
          super
          columns_count = read_int16
          @columns = Array.new(columns_count) do
            length = read_int32
            next if length == 4_294_967_295
            read_bytes(length)
          end
        end
      end
    end
  end
end
