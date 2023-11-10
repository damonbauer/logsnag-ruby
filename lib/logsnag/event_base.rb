# frozen_string_literal: true

module LogSnag
  # Provides a base class for LogSnag events.
  # Ensures that the data hash is valid and that the configuration object is present.
  # @abstract Subclass and override {#data} and {#config} to implement.
  # @attr_reader data [Hash] The data to be sent to LogSnag.
  # @attr_reader config [LogSnag::Configuration] The configuration object.
  # @raise [ArgumentError] If the hash is missing required keys or contains invalid keys.
  # @return [LogSnag::EventBase] The new EventBase object.
  class EventBase
    attr_reader :data, :config

    def initialize(data, config)
      @data = data
      @config = config

      raise ArgumentError, "`data` must be a Hash" unless data.is_a?(Hash)

      return if config.is_a?(LogSnag::Configuration)

      raise ArgumentError,
            "LogSnag::Configuration not found. Did you call LogSnag.configure?"
    end

    def to_json(*_args)
      data.to_json
    end
  end
end
