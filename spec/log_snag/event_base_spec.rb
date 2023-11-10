# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/logsnag/event_base"

RSpec.describe LogSnag::EventBase do
  subject(:event_base) { described_class }

  let(:data) { { foo: "bar" } }
  let(:config) { LogSnag::Configuration.new }

  describe "#initialize" do
    context "when the `data` argument is not a hash" do
      let(:data) { "not a hash" }

      it "raises an exception" do
        expect do
          event_base.new(data, config)
        end.to raise_error(ArgumentError, "`data` must be a Hash")
      end
    end

    context "when the `data` argument is a hash" do
      context "when the `config` argument is not a LogSnag::Configuration object" do
        let(:config) { "not a config" }

        it "raises an exception" do
          expect do
            event_base.new(data, config)
          end.to raise_error(ArgumentError, "LogSnag::Configuration not found. Did you call LogSnag.configure?")
        end
      end

      context "when the `config` argument is a LogSnag::Configuration object" do
        it "does not raise an exception" do
          expect do
            event_base.new(data, config)
          end.not_to raise_error
        end
      end
    end
  end

  describe "#to_json" do
    it "returns a JSON representation of the data" do
      expect(event_base.new(data, config).to_json).to eq(data.to_json)
    end
  end
end
