require "terakoya/version"
require "terakoya/engine"
require "terakoya/configuration"

module Terakoya
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def config
      self.configuration ||= Configuration.new
    end
  end
end
