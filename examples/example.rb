# frozen_string_literal: true

require_relative '../lib/extended_query_postgres_driver'

ExtendedQueryPostgresDriver.configure do |config|
  config.database = 'test_database'
  config.user = 'test_user'
  config.password = '123456'
end

connection = ExtendedQueryPostgresDriver::Connection.new
p connection
socket = connection.socket
messages = ExtendedQueryPostgresDriver::Messages

messages.write(socket, 'P', query: 'select oid, typname from pg_type where typname ilike $1 OR typname ilike $2;')
messages.write(socket, 'B', parameter_values: [StringIO.new('int%'), 't%'])
messages.write(socket, 'D')
messages.write(socket, 'E')
messages.write(socket, 'S')

fields = []
result = []

loop do
  response = messages.read(socket)
  p response, response.class::TYPE
  case response
  when messages::Backend::RowDescription
    fields = response.fields.map { |field| field[:name].to_sym }
  when messages::Backend::DataRow
    row = fields.each_with_object({}).with_index do |(field, memo), i|
      memo[field] = response.columns[i]
    end
    result.push(row)
  when messages::Backend::ReadyForQuery
    @transaction_status = response.transaction_status
    break
  end
end

p result
