# frozen_string_literal: true

require 'pp'
require_relative '../lib/extended_query_postgres_driver'

connection = ExtendedQueryPostgresDriver::Connection.new
p connection
pp connection.test_query
p connection
