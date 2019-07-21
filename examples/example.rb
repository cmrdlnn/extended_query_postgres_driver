# frozen_string_literal: true

require_relative '../lib/extended_query_postgres_driver'

ExtendedQueryPostgresDriver.configure do |config|
  config.database = 'test_database'
  config.user     = 'test_user'
  config.password = '123456'
end

connection = ExtendedQueryPostgresDriver::Connection.new

connection.parse(query: 'DROP TABLE IF EXISTS files;')
connection.bind
connection.execute

connection.parse(query: 'CREATE TABLE files (content text);')
connection.bind
connection.execute

file = File.open(File.join(__dir__, 'iso_8859-1.txt'))
connection.parse(query: 'INSERT INTO files VALUES ($1);')
connection.bind(format_codes: [1], parameters: [file])
connection.execute

connection.parse(query: 'SELECT * FROM files;')
connection.bind
connection.describe
connection.execute

connection.sync

p connection.result
