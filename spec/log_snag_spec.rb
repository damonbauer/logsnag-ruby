# frozen_string_literal: true

require "spec_helper"

RSpec.describe LogSnag do
  let(:mock_response) { { message: "Event logged" }.to_json }

  describe ".configure" do
    before do
      described_class.configure do |config|
        config.api_token = "123456"
        config.project = "test-project"
        config.logger = Logger.new($stdout)
      end
    end

    it "correctly sets the configuration options" do
      expect(described_class.config.api_token).to eq("123456")
      expect(described_class.config.project).to eq("test-project")
      expect(described_class.config.logger).to be_a(Logger)
    end
  end

  describe ".log" do
    let(:data) do
      {
        channel: "test-channel",
        event: "test-event"
      }
    end

    before do
      described_class.configure do |config|
        config.api_token = "123456"
        config.project = "test-project"
        config.logger = Logger.new($stdout)
      end

      stub_request(:post, "https://api.logsnag.com/v1/log")
        .with(
          body: data.merge({ project: described_class.config.project }).to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{described_class.config.api_token}"
          }
        )
        .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
    end

    it "sends an event log to LogSnag" do
      result = described_class.log(data)

      expect(a_request(:post, "https://api.logsnag.com/v1/log")
               .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

      expect(result.success).to be(true)
      expect(result.data).to eq({ "message" => "Event logged" })
      expect(result.error_message).to be_nil
      expect(result.status_code).to eq(200)
    end

    context "when the HTTP request fails" do
      let(:mock_response) { { message: "Event log failed" }.to_json }

      before do
        stub_request(:post, "https://api.logsnag.com/v1/log")
          .with(
            body: data.merge({ project: described_class.config.project }).to_json,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer #{described_class.config.api_token}"
            }
          )
          .to_return(status: 400, body: mock_response, headers: { "Content-Type" => "application/json" })
      end

      it "returns the expected result" do
        result = described_class.log(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/log")
                 .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Event log failed")
        expect(result.status_code).to eq(400)
      end
    end

    context "when HTTParty::Error is raised" do
      before do
        allow(described_class).to receive(:post).and_raise(HTTParty::Error, "Mocked HTTParty Error")
      end

      it "returns the expected result" do
        result = described_class.log(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/log")).not_to have_been_made

        expect(result).to be_a(LogSnag::Result)
        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Mocked HTTParty Error")
        expect(result.status_code).to be_nil
      end
    end

    context "when required key/value pairs are not provided" do
      let(:data) do
        # Missing `event` key
        {
          channel: "test"
        }
      end

      it "raises an exception" do
        expect do
          described_class.log(data)
        end.to raise_error(ArgumentError, "Missing required keys: [:event]")

        expect(a_request(:post, "https://api.logsnag.com/v1/log")).not_to have_been_made
      end
    end

    context "when a non-allowed key is provided" do
      let(:data) do
        # `foo` is not allowed
        {
          event: "test-event",
          channel: "test",
          foo: "bar"
        }
      end

      it "raises an exception" do
        expect do
          described_class.log(data)
        end.to raise_error(ArgumentError, "Found invalid keys: [:foo]")

        expect(a_request(:post, "https://api.logsnag.com/v1/log")).not_to have_been_made
      end
    end

    context "when `tags` are provided in event data" do
      context "when `nil` values are provided" do
        let(:data) do
          {
            channel: "test",
            event: "test-event",
            tags: { source: "api", status: nil }
          }
        end

        let(:stripped_data) do
          data.dup.tap do |data|
            data[:tags] = data[:tags].compact
            data[:project] = described_class.config.project
          end
        end

        before do
          stub_request(:post, "https://api.logsnag.com/v1/log")
            .with(
              body: stripped_data.to_json,
              headers: {
                "Content-Type" => "application/json",
                "Authorization" => "Bearer 123456"
              }
            )
            .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
        end

        it "strips `nil` values before sending an event log to LogSnag" do
          result = described_class.log(data)

          expect(a_request(:post, "https://api.logsnag.com/v1/log")
                   .with(body: stripped_data.to_json)).to have_been_made.once

          expect(result.success).to be(true)
          expect(result.data).to eq({ "message" => "Event logged" })
          expect(result.error_message).to be_nil
          expect(result.status_code).to eq(200)
        end
      end
    end
  end

  describe ".identify" do
    let(:data) do
      {
        user_id: "test-user-id",
        properties: { email: "test-user@example.com" }
      }
    end

    before do
      described_class.configure do |config|
        config.api_token = "123456"
        config.project = "test-project"
        config.logger = Logger.new($stdout)
      end

      stub_request(:post, "https://api.logsnag.com/v1/identify")
        .with(
          body: data.merge({ project: described_class.config.project }).to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{described_class.config.api_token}"
          }
        )
        .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
    end

    it "sends an 'identify' call to LogSnag" do
      result = described_class.identify(data)

      expect(a_request(:post, "https://api.logsnag.com/v1/identify")
               .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

      expect(result.success).to be(true)
      expect(result.data).to eq({ "message" => "Event logged" })
      expect(result.error_message).to be_nil
      expect(result.status_code).to eq(200)
    end

    context "when the HTTP request fails" do
      let(:mock_response) { { message: "Event log failed" }.to_json }

      before do
        stub_request(:post, "https://api.logsnag.com/v1/identify")
          .with(
            body: data.merge({ project: described_class.config.project }).to_json,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer #{described_class.config.api_token}"
            }
          )
          .to_return(status: 400, body: mock_response, headers: { "Content-Type" => "application/json" })
      end

      it "returns the expected result" do
        result = described_class.identify(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/identify")
                 .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Event log failed")
        expect(result.status_code).to eq(400)
      end
    end

    context "when HTTParty::Error is raised" do
      before do
        allow(described_class).to receive(:post).and_raise(HTTParty::Error, "Mocked HTTParty Error")
      end

      it "returns the expected result" do
        result = described_class.identify(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/identify")).not_to have_been_made

        expect(result).to be_a(LogSnag::Result)
        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Mocked HTTParty Error")
        expect(result.status_code).to be_nil
      end
    end

    context "when required key/value pairs are not provided" do
      let(:data) do
        # Missing `properties` key
        {
          user_id: "test-user-id"
        }
      end

      it "raises an exception" do
        expect do
          described_class.identify(data)
        end.to raise_error(ArgumentError, "Missing required keys: [:properties]")

        expect(a_request(:post, "https://api.logsnag.com/v1/identify")).not_to have_been_made
      end
    end

    context "when `properties` are provided in event data" do
      context "when `nil` values are provided" do
        let(:data) do
          {
            user_id: "test-user-id",
            properties: { name: "test-user-name", plan: nil }
          }
        end

        let(:stripped_data) do
          data.dup.tap do |data|
            data[:properties] = data[:properties].compact
            data[:project] = described_class.config.project
          end
        end

        before do
          stub_request(:post, "https://api.logsnag.com/v1/identify")
            .with(
              body: stripped_data.to_json,
              headers: {
                "Content-Type" => "application/json",
                "Authorization" => "Bearer 123456"
              }
            )
            .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
        end

        it "strips `nil` values before sending an 'identify' log to LogSnag" do
          result = described_class.identify(data)

          expect(a_request(:post, "https://api.logsnag.com/v1/identify")
                   .with(body: stripped_data.to_json)).to have_been_made.once

          expect(result.success).to be(true)
          expect(result.data).to eq({ "message" => "Event logged" })
          expect(result.error_message).to be_nil
          expect(result.status_code).to eq(200)
        end
      end
    end
  end

  describe ".insight" do
    let(:data) do
      {
        title: "test-title",
        value: 123
      }
    end

    before do
      described_class.configure do |config|
        config.api_token = "123456"
        config.project = "test-project"
        config.logger = Logger.new($stdout)
      end

      stub_request(:post, "https://api.logsnag.com/v1/insight")
        .with(
          body: data.merge({ project: described_class.config.project }).to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{described_class.config.api_token}"
          }
        )
        .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
    end

    it "sends an 'insight' call to LogSnag" do
      result = described_class.insight(data)

      expect(a_request(:post, "https://api.logsnag.com/v1/insight")
               .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

      expect(result.success).to be(true)
      expect(result.data).to eq({ "message" => "Event logged" })
      expect(result.error_message).to be_nil
      expect(result.status_code).to eq(200)
    end

    context "when the HTTP request fails" do
      let(:mock_response) { { message: "Event log failed" }.to_json }

      before do
        stub_request(:post, "https://api.logsnag.com/v1/insight")
          .with(
            body: data.merge({ project: described_class.config.project }).to_json,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer #{described_class.config.api_token}"
            }
          )
          .to_return(status: 400, body: mock_response, headers: { "Content-Type" => "application/json" })
      end

      it "returns the expected result" do
        result = described_class.insight(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/insight")
                 .with(body: data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

        expect(result).to be_a(LogSnag::Result)
        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Event log failed")
        expect(result.status_code).to eq(400)
      end
    end

    context "when HTTParty::Error is raised" do
      before do
        allow(described_class).to receive(:post).and_raise(HTTParty::Error, "Mocked HTTParty Error")
      end

      it "returns the expected result" do
        result = described_class.insight(data)

        expect(a_request(:post, "https://api.logsnag.com/v1/insight")).not_to have_been_made

        expect(result).to be_a(LogSnag::Result)
        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Mocked HTTParty Error")
        expect(result.status_code).to be_nil
      end
    end

    context "when `value` field is incorrect type" do
      let(:value) { { foo: "bar" } }
      let(:data) do
        {
          title: "test-title",
          value: value
        }
      end

      it "raises an exception" do
        expect do
          described_class.insight(data)
        end.to raise_error(ArgumentError, "Invalid value for Insight: '#{value}'. Values must be a string or number.")
      end
    end
  end

  describe ".mutate_insight" do
    let(:data) do
      {
        title: "test-title",
        value: 1
      }
    end

    let(:expected_data) do
      {
        title: "test-title",
        value: {
          "$inc": 1
        }
      }
    end

    before do
      described_class.configure do |config|
        config.api_token = "123456"
        config.project = "test-project"
        config.logger = Logger.new($stdout)
      end

      stub_request(:patch, "https://api.logsnag.com/v1/insight")
        .with(
          body: expected_data.merge({ project: described_class.config.project }).to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{described_class.config.api_token}"
          }
        )
        .to_return(status: 200, body: mock_response, headers: { "Content-Type" => "application/json" })
    end

    it "sends an 'insight' mutation call to LogSnag" do
      result = described_class.mutate_insight(data)

      expect(a_request(:patch, "https://api.logsnag.com/v1/insight")
               .with(body: expected_data.merge({ project: described_class.config.project }).to_json)).to have_been_made.once

      expect(result.success).to be(true)
      expect(result.data).to eq({ "message" => "Event logged" })
      expect(result.error_message).to be_nil
      expect(result.status_code).to eq(200)
    end

    context "when `value` field is incorrect type" do
      let(:value) { "not-a-number" }
      let(:data) do
        {
          title: "test-title",
          value: value
        }
      end

      it "raises an exception" do
        expect do
          described_class.mutate_insight(data)
        end.to raise_error(ArgumentError, "Invalid value for Insight mutation: '#{value}'. Value must be a number.")
      end
    end

    context "when HTTParty::Error is raised" do
      before do
        allow(described_class).to receive(:patch).and_raise(HTTParty::Error, "Mocked HTTParty Error")
      end

      it "returns the expected result" do
        result = described_class.mutate_insight(data)

        expect(a_request(:patch, "https://api.logsnag.com/v1/insight")).not_to have_been_made

        expect(result).to be_a(LogSnag::Result)
        expect(result.success).to be(false)
        expect(result.data).to be_nil
        expect(result.error_message).to eq("Mocked HTTParty Error")
        expect(result.status_code).to be_nil
      end
    end
  end
end
