# frozen_string_literal: true

require_relative "event_base"
require_relative "validator"

module LogSnag
  # Constructs and validates an "identify" object
  class Identify < EventBase
    REQUIRED_KEYS = %i[project user_id properties].freeze

    attr_reader :data, :config

    # Creates a new Identify object.
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash must include the following keys:
    #   - :user_id [String] The user ID of the user to be identified.
    #   - :properties [Hash] The properties of the user to be identified.
    # @param config [LogSnag::Configuration] The configuration object.
    # @see https://docs.logsnag.com/api-reference/identify
    # @raise [ArgumentError] If the hash is missing required keys, has invalid keys, or has values of incorrect types.
    # @return [LogSnag::Insight] The new Identify object.
    def initialize(data, config)
      super(data, config)

      append_required_fields!
      compact_properties!
      validate_data
    end

    private

    def append_required_fields!
      data[:project] = config.project
      data
    end

    def compact_properties!
      Validator.compact_hash!(data, :properties)
    end

    def validate_data
      Validator.validate_required_keys(REQUIRED_KEYS, data)
      Validator.validate_hash(data[:properties])
    end
  end
end
