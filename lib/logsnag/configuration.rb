# frozen_string_literal: true

module LogSnag
  # Configuration class for storing API token, project, and logger
  class Configuration
    attr_accessor :logger
    attr_reader :api_token, :project

    def api_token=(token)
      raise ArgumentError, "API token cannot be nil" if token.nil? || token.empty?

      @api_token = token
    end

    def project=(project_name)
      raise ArgumentError, "Project cannot be nil" if project_name.nil? || project_name.empty?

      @project = project_name
    end
  end
end
