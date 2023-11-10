# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/logsnag/validator"

RSpec.describe LogSnag::Validator do
  subject(:validator) { described_class }

  describe ".validate_required_keys" do
    context "when all required keys are present" do
      it "does not raise an exception" do
        expect do
          validator.validate_required_keys(%i[foo bar], { foo: "value", bar: "value" })
        end.not_to raise_error
      end
    end

    context "when a required key is missing" do
      it "raises an exception" do
        expect do
          validator.validate_required_keys(%i[foo bar], { foo: "value" })
        end.to raise_error(ArgumentError, "Missing required keys: [:bar]")
      end
    end
  end

  describe ".validate_allowed_keys" do
    context "when all provided keys are allowed" do
      it "does not raise an exception" do
        expect do
          validator.validate_allowed_keys(%i[foo bar], { foo: "value", bar: "value" })
        end.not_to raise_error
      end
    end

    context "when a provided key is not allowed" do
      it "raises an exception" do
        expect do
          validator.validate_allowed_keys(%i[foo bar], { foo: "value", bar: "value", baz: "value" })
        end.to raise_error(ArgumentError, "Found invalid keys: [:baz]")
      end
    end
  end

  describe ".compact_hash!" do
    context "when the provided path is found in the hash" do
      let(:input) do
        { keyA: { keyB: "valueB", keyC: nil } }
      end

      it "removes the key/value pair from the hash" do
        result = validator.compact_hash!(input, :keyA)
        expect(result).to eq({ keyA: { keyB: "valueB" } })
      end
    end

    context "when the provided path is not found in the hash" do
      let(:input) do
        { keyA: { keyB: "valueB", keyC: "valueC" } }
      end

      it "does not remove anything from the hash" do
        result = validator.compact_hash!(input, :keyC)
        expect(result).to eq({ keyA: { keyB: "valueB", keyC: "valueC" } })
      end
    end
  end

  describe ".validate_hash" do
    hashes = [
      { SomeKey: "invalid" },
      { Foo!: "invalid" },
      { "-foo": "invalid" },
      { "foo-": "invalid" },
      { foo_bar: "invalid" },
      { "12345": "invalid" }
    ]
    context "when an invalid key is provided" do
      hashes.each do |hash|
        it "raises an exception for invalid key" do
          expect do
            validator.validate_hash(hash)
          end.to raise_error(ArgumentError,
                             "Invalid key: '#{hash.keys.first}'. Keys must be lowercase and may include dashes.")
        end
        # include_examples "invalid hash key", hash
      end
    end

    context "when an invalid value is provided" do
      hashes = [
        { foo: [1, 2, 3] },
        { foo: { complex: "object" } }
      ]

      hashes.each do |hash|
        it "raises an exception for invalid value" do
          expect do
            validator.validate_hash(hash)
          end.to raise_error(ArgumentError,
                             "Invalid value for '#{hash.keys.first}': '#{hash.values.first}'. Values must be a string, boolean, or number.")
        end
      end
    end
  end
end
