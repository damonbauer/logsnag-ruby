# frozen_string_literal: true

require_relative "event_base"
require_relative "validator"

module LogSnag
  # Constructs and validates an event log
  class Log < EventBase
    REQUIRED_KEYS = %i[project channel event].freeze
    ALLOWED_KEYS = REQUIRED_KEYS + %i[
      user_id description icon notify tags parser timestamp
    ].freeze

    # attr_reader :data, :config

    # Creates a new Log object.
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash must include the following keys:
    #   - :channel [String] The channel within the project to which the log belongs.
    #   - :event [String] The name of the event.
    # The data hash may include the following keys:
    #   - :user_id [String] The user ID of the user to be identified.
    #   - :description [String] The description of the event.
    #   - :icon [String] The icon to be displayed with the event.
    #   - :notify [Boolean] Whether or not to send a push notification for the event.
    #   - :tags [Hash] The tags to be associated with the event.
    #   - :parser [String] The parser to be used for the event. One of "text" or "markdown".
    #   - :timestamp [Numeric] The timestamp of the event (in Unix seconds).
    # @param config [LogSnag::Configuration] The configuration object.
    # @see https://docs.logsnag.com/api-reference/log
    # @raise [ArgumentError] If the hash is missing required keys, has invalid keys, or has values of incorrect types.
    # @return [LogSnag::Insight] The new Identify object.
    def initialize(data, config)
      super(data, config)

      append_required_fields!
      compact_tags!
      validate_data
    end

    private

    def append_required_fields!
      data[:project] = config.project
      data
    end

    def compact_tags!
      Validator.compact_hash!(data, :tags)
    end

    def validate_data
      Validator.validate_required_keys(REQUIRED_KEYS, data)
      Validator.validate_allowed_keys(ALLOWED_KEYS, data)
      Validator.validate_hash(data[:tags])
    end
  end
end
