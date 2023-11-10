# frozen_string_literal: true

require_relative "event_base"
require_relative "validator"

module LogSnag
  # Constructs and validates an "insight" object
  class Insight < EventBase
    REQUIRED_KEYS = %i[project title value].freeze

    attr_reader :data, :config

    # Creates a new Insight object.
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash MUST include the following keys:
    #   - :title [String] The title of the insight.
    #   - :value [String,Numeric] The numerical value of the insight.
    # The data hash MAY include the following keys:
    #   - :icon [String] The icon to be displayed with the insight.
    # @param config [LogSnag::Configuration] The configuration object.
    # @param mutate [Boolean] Whether or not to mutate the data hash.
    # @see https://docs.logsnag.com/api-reference/insight
    # @raise [ArgumentError] If the hash is missing required keys, has invalid keys, or has values of incorrect types.
    # @return [LogSnag::Insight] The new Insight object.
    def initialize(data, config, mutate: false)
      super(data, config)

      append_required_fields!

      if mutate
        validate_mutation_data
      else
        validate_data
      end
    end

    private

    def append_required_fields!
      data[:project] = config.project
      data
    end

    def validate_mutation_data
      Validator.validate_required_keys(REQUIRED_KEYS, data)
      validate_mutation_values
    end

    def validate_data
      Validator.validate_required_keys(REQUIRED_KEYS, data)
      validate_values
    end

    def validate_mutation_values
      return if [Numeric].any? { |type| data[:value].is_a?(type) }

      raise ArgumentError, "Invalid value for Insight mutation: '#{data[:value]}'. Value must be a number."
    end

    def validate_values
      return if [String, Numeric].any? { |type| data[:value].is_a?(type) }

      raise ArgumentError, "Invalid value for Insight: '#{data[:value]}'. Values must be a string or number."
    end
  end
end
