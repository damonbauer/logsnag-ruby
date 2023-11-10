# frozen_string_literal: true

require "httparty"
require "json"

require_relative "logsnag/version"
require_relative "logsnag/configuration"
require_relative "logsnag/log"
require_relative "logsnag/identify"
require_relative "logsnag/insight"
require_relative "logsnag/result"

# The main module for the LogSnag gem, containing methods for sending logs to LogSnag.
module LogSnag
  include HTTParty

  base_uri "https://api.logsnag.com/v1"
  PATHS = {
    LOG: "/log",
    IDENTIFY: "/identify",
    INSIGHT: "/insight"
  }.freeze

  class << self
    attr_accessor :config

    # Configures LogSnag with the provided configuration options.
    # @yield [LogSnag::Configuration] The configuration object.
    def configure
      self.config ||= LogSnag::Configuration.new
      yield(config)
    end

    # Sends an event log to LogSnag.
    #
    # Logs are the core of LogSnag. They are used to track events in your application. These events could be
    # anything from user actions to server events, such as a database running out of space or a server crash.
    #
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash MUST include the following keys:
    #   - :channel [String] The channel within the project to which the log belongs.
    #   - :event [String] The name of the event.
    # The data hash MAY include the following keys:
    #   - :user_id [String] The user ID of the user to be identified.
    #   - :description [String] The description of the event.
    #   - :icon [String] The icon to be displayed with the event.
    #   - :notify [Boolean] Whether or not to send a push notification for the event.
    #   - :tags [Hash] The tags to be associated with the event.
    #   - :parser [String] The parser to be used for the event. One of "text" or "markdown".
    #   - :timestamp [Numeric] The timestamp of the event (in Unix seconds).
    # @see https://docs.logsnag.com/api-reference/log
    # @raise [ArgumentError] If the hash is missing required keys or contains invalid keys.
    # @return [LogSnag::Result] The formatted result from the request.
    def log(data = {})
      event = LogSnag::Log.new(data, config)
      execute_post(PATHS[:LOG], event)
    end

    # Sends an identify log to LogSnag.
    #
    # The identify endpoint lets you add key-value properties to a user profile.
    # This endpoint is optional and useful for getting a complete picture of a user just by looking at their profile,
    # and additionally, these properties can be used for filtering and searching.
    #
    # For example, you may add a user's email address, their plan, last payment date, etc., to their profile and
    # then use these properties to filter and search for users, such as searching for all users on a specific plan.
    #
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash MUST include the following keys:
    #   - :user_id [String] The user ID of the user to be identified.
    #   - :properties [Hash] The properties of the user to be identified.
    # @see https://docs.logsnag.com/api-reference/identify
    # @raise [ArgumentError] If the hash is missing required keys or contains invalid keys.
    # @return [LogSnag::Result] The formatted result from the request.
    def identify(data = {})
      event = LogSnag::Identify.new(data, config)
      execute_post(PATHS[:IDENTIFY], event)
    end

    # Sends an insight log to LogSnag.
    #
    # Insights are real-time widgets that you can add to each of your projects.
    # They are use-case agnostic and can be used to display any information that you want in real-time.
    #
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash MUST include the following keys:
    #   - :title [String] The title of the insight.
    #   - :value [String,Numeric] The numerical value of the insight.
    # @see https://docs.logsnag.com/api-reference/insight
    # @raise [ArgumentError] If the hash is missing required keys, has invalid keys, or has values of incorrect types.
    # @return [LogSnag::Result] The formatted result from the request.
    def insight(data = {})
      event = LogSnag::Insight.new(data, config)
      execute_post(PATHS[:INSIGHT], event)
    end

    # Mutate an insight to LogSnag.
    # This endpoint allows you to change (mutate) existing numerical insights.
    # @param data [Hash] The data to be sent to LogSnag.
    # The data hash MUST include the following keys:
    #   - :title [String] The title of the insight.
    #   - :value [Numeric] The numerical value of the insight.
    # The data hash MAY include the following keys:
    #   - :icon [String] The icon to be displayed with the event.
    # @see https://docs.logsnag.com/api-reference/insight-mutate
    # @raise [ArgumentError] If the hash is missing required keys, has invalid keys, or has values of incorrect types.
    # @return [LogSnag::Result] The formatted result from the request.
    def mutate_insight(data = {})
      event = LogSnag::Insight.new(data, config, mutate: true)
      execute_patch(PATHS[:INSIGHT], event)
    end

    private

    # Executes a POST request to the specified path with the provided body.
    # @param path [String] The path to which the request should be made.
    # @param body [LogSnag::Log,LogSnag::Identify,LogSnag::Insight] The body of the request.
    # @return [LogSnag::Result] The formatted result from the request.
    def execute_post(path, body)
      response = post(
        path,
        body: body.to_json,
        headers: headers
      )

      handle_response(response)
    rescue HTTParty::Error => e
      Result.new(success: false, error_message: e.message, status_code: nil)
    end

    # Executes a PATCH request to the specified path with the provided body.
    # @param path [String] The path to which the request should be made.
    # @param body [LogSnag::Insight] The body of the request.
    # @return [LogSnag::Result] The formatted result from the request.
    def execute_patch(path, body)
      response = patch(
        path,
        body: {
          **body.data,
          value: {
            "$inc": body.data[:value]
          }
        }.to_json,
        headers: headers
      )

      handle_response(response)
    rescue HTTParty::Error => e
      Result.new(success: false, error_message: e.message, status_code: nil)
    end

    # Handles the response from the HTTP request.
    # @param response [HTTParty::Response] The response from the HTTP request.
    # @return [LogSnag::Result] The formatted result from the request.
    def handle_response(response)
      if response.success?
        Result.new(success: true, data: response.parsed_response, status_code: response.code)
      else
        error_message = response.parsed_response["message"] || response.body
        Result.new(success: false, error_message: error_message, status_code: response.code)
      end
    end

    # Returns the headers to be used in the HTTP request.
    # @return [Hash] The headers to be used in the HTTP request.
    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{config.api_token}"
      }
    end
  end
end
