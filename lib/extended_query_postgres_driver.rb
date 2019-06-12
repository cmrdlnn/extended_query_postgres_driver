# frozen_string_literal: true

require_relative 'extended_query_postgres_driver/messages'
require_relative 'extended_query_postgres_driver/connection'

module ExtendedQueryPostgresDriver
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Struct.new(
        :type,
        :host,
        :port,
        :options,
        :database,
        :user,
        :password,
        :replication
      ).new('tcp', 'localhost', '5432', [])
    end
  end
end
