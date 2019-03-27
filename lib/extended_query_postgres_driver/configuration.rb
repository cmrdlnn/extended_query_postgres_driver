# frozen_string_literal: true

require 'singleton'

module ExtendedQueryPostgresDriver
  class Configuration
    include Singleton

    def self.configure
      instance.configure
    end

    def configure
      yield config
    end

    def config
      @config ||= Struct.new
    end
  end
end
