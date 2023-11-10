# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/logsnag/result"

RSpec.describe LogSnag::Result do
  let(:success_result) do
    described_class.new(success: true, data: "data", error_message: nil, status_code: 200)
  end
  let(:failure_result) do
    described_class.new(success: false, data: nil, error_message: "error", status_code: 400)
  end

  describe "#initialize" do
    it "correctly assigns attributes" do
      expect(success_result.success).to be true
      expect(success_result.data).to eq("data")
      expect(success_result.error_message).to be_nil
      expect(success_result.status_code).to eq(200)

      expect(failure_result.success).to be false
      expect(failure_result.data).to be_nil
      expect(failure_result.error_message).to eq("error")
      expect(failure_result.status_code).to eq(400)
    end
  end

  describe "#success?" do
    it "returns true if the result is successful" do
      expect(success_result.success?).to be true
    end

    it "returns false if the result is not successful" do
      expect(failure_result.success?).to be false
    end
  end

  describe "#error?" do
    it "returns false if the result is successful" do
      expect(success_result.error?).to be false
    end

    it "returns true if the result is not successful" do
      expect(failure_result.error?).to be true
    end
  end
end
