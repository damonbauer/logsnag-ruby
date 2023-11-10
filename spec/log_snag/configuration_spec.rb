# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/logsnag/configuration"

RSpec.describe LogSnag::Configuration do
  subject(:configuration) { described_class.new }

  describe "#api_token=" do
    context "when provided a valid token" do
      it "sets the api_token" do
        configuration.api_token = "valid_token"
        expect(configuration.api_token).to eq("valid_token")
      end
    end

    context "when provided nil" do
      it "raises an ArgumentError" do
        expect { configuration.api_token = nil }.to raise_error(ArgumentError, "API token cannot be nil")
      end
    end

    context "when provided an empty string" do
      it "raises an ArgumentError" do
        expect { configuration.api_token = "" }.to raise_error(ArgumentError, "API token cannot be nil")
      end
    end
  end

  describe "#project=" do
    context "when provided a valid project name" do
      it "sets the project" do
        configuration.project = "valid_project"
        expect(configuration.project).to eq("valid_project")
      end
    end

    context "when provided nil" do
      it "raises an ArgumentError" do
        expect { configuration.project = nil }.to raise_error(ArgumentError, "Project cannot be nil")
      end
    end

    context "when provided an empty string" do
      it "raises an ArgumentError" do
        expect { configuration.project = "" }.to raise_error(ArgumentError, "Project cannot be nil")
      end
    end
  end

  describe "#logger" do
    it "allows setting and getting the logger" do
      logger = Logger.new($stdout)
      configuration.logger = logger
      expect(configuration.logger).to eq(logger)
    end
  end
end
