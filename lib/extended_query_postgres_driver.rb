# frozen_string_literal: true

require_relative 'extended_query_postgres_driver/messages/frontend'
require_relative 'extended_query_postgres_driver/messages/backend'
require_relative 'extended_query_postgres_driver/connection'

# Main namespace that is entry point to the library
module ExtendedQueryPostgresDriver
  class << self
    # Configure the database connection settings
    # @yieldparam [Struct::Config] config Configuration object with database
    #   connection settings
    def configure
      yield config
    end

    # Creates configuration object if it doesn't exist with default database
    # connection settings or just return existed object
    # @return [Struct::Config] Configuration object with database connection
    #   settings
    def config
      @config ||= Struct.new(
        'Config',
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
