# logsnag-ruby

Interact with the [LogSnag](https://logsnag.com) API to send logs, identify users, and send insights.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logsnag-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install logsnag-ruby
```

## Configuration

Before you can send logs to LogSnag, you need to configure the gem with your API token and project name.
This is typically done in an initializer in your application.
For example:

```ruby
# config/initializers/logsnag.rb

LogSnag.configure do |config|
  config.api_token = "your_api_token"
  config.project = "your_project_name"
end
```

## Usage

The `logsnag-ruby` gem provides several methods to interact with the LogSnag API.

Each method will automatically add the `project` and `api_token` parameters to the request.

### Logging Events

To send an event log:

```ruby
LogSnag.log({
  channel: "server",
  event: "server_start",
  # ... other optional parameters ...
})
```

**Arguments:**

- `data`: A hash containing the event data.
    - **Required keys:**
        - `channel` [String]: The channel within the project to which the log belongs.
        - `event` [String]: The name of the event.
    - Optional keys:
        - `user_id` [String]: The user ID of the user related to the event.
        - `description` [String]: The description of the event.
        - `icon` [String]: The icon to be displayed with the event.
        - `notify` [Boolean]: Whether to send a push notification for the event.
        - `tags` [Hash]: The tags associated with the event. See [the LogSnag docs](https://docs.logsnag.com/api-reference/log#tags) for more information regarding the format of the `tags` hash.
        - `parser` [String]: The parser to be used for the event. One of "text" or "markdown".
        - `timestamp` [Numeric]: The timestamp of the event (in Unix seconds).

**Returns:**

- `LogSnag::Result`: A result object with the following methods:
    - `success?`: Returns `true` if the request was successful.
    - `error?`: Returns `true` if the request failed.
    - `data`: The parsed response data from the server.
    - `error_message`: The error message if the request failed.
    - `status_code`: The HTTP status code of the response.

### Identifying Users

To add or update properties to a user profile:

```ruby
LogSnag.identify({
  user_id: "user_123",
  properties: {
    email: "user@example.com",
    plan: "premium"
  }
})
```

**Arguments:**

- `data`: A hash containing the identification data.
    - **Required keys:**
        - `user_id` [String]: The user ID of the user to be identified.
        - `properties` [Hash]: The properties of the user to be identified. See [the LogSnag docs](https://docs.logsnag.com/api-reference/identify#properties-schema) for more information regarding the format of the `properties` hash.

**Returns:**

- `LogSnag::Result`: A result object with the following methods:
    - `success?`: Returns `true` if the request was successful.
    - `error?`: Returns `true` if the request failed.
    - `data`: The parsed response data from the server.
    - `error_message`: The error message if the request failed.
    - `status_code`: The HTTP status code of the response.

### Sending Insights

To send an insight log:

```ruby
LogSnag.insight({
  title: "New Signups",
  value: 42,
  # ... other optional parameters ...
})
```

**Arguments:**

- `data`: A hash containing the insight data.
    - **Required keys:**
        - `title` [String]: The title of the insight.
        - `value` [String, Numeric]: The numerical value of the insight.
    - Optional keys:
        - `icon` [String]: The icon to be displayed with the insight.

**Returns:**

- `LogSnag::Result`: A result object with the following methods:
    - `success?`: Returns `true` if the request was successful.
    - `error?`: Returns `true` if the request failed.
    - `data`: The parsed response data from the server.
    - `error_message`: The error message if the request failed.
    - `status_code`: The HTTP status code of the response.

### Mutating Insights

To mutate (increment) an existing numerical insight:

```ruby
LogSnag.mutate_insight({ 
  title: "Total Users", 
  value: 5
})
```

**Arguments:**

- `data`: A hash containing the insight mutation data.
    - **Required keys:**
        - `title` [String]: The title of the insight.
        - `value` [Numeric]: The amount to increment the insight by.
    - Optional keys:
        - `icon` [String]: The icon to be displayed with the insight.

**Returns:**

- `LogSnag::Result`: A result object with the following methods:
    - `success?`: Returns `true` if the request was successful.
    - `error?`: Returns `true` if the request failed.
    - `data`: The parsed response data from the server.
    - `error_message`: The error message if the request failed.
    - `status_code`: The HTTP status code of the response.

## Contributing

Bug reports and pull requests are welcome on GitHub
at [https://github.com/damonbauer/logsnag-ruby](https://github.com/damonbauer/logsnag-ruby).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
