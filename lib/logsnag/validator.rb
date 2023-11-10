# frozen_string_literal: true

module LogSnag
  # Provides helpers for validating data.
  class Validator
    # Ensure that the `required_keys` are present in the `data` hash.
    # @param required_keys [Array<Symbol>] The keys that must be present in the hash.
    # @param data [Hash] The hash to be validated.
    # @raise [ArgumentError] If the hash is missing required keys.
    # @return [void]
    def self.validate_required_keys(required_keys, data)
      missing_keys = required_keys - data.keys
      raise ArgumentError, "Missing required keys: #{missing_keys}" unless missing_keys.empty?
    end

    # Ensure that the `data` hash only contains keys in the `allowed_keys` array.
    # @param allowed_keys [Array<Symbol>] The keys that are allowed in the hash.
    # @param data [Hash] The hash to be validated.
    # @raise [ArgumentError] If the hash contains invalid keys.
    # @return [void]
    def self.validate_allowed_keys(allowed_keys, data)
      invalid_keys = data.keys - allowed_keys
      raise ArgumentError, "Found invalid keys: #{invalid_keys}" unless invalid_keys.empty?
    end

    # Removes any nil values from the hash at the specified path.
    # @param hash [Hash] The hash from which to remove nil values.
    # @param path [Symbol] The path to the hash to be compacted.
    # @return [Hash] The hash with nil values removed.
    def self.compact_hash!(hash, path)
      hash[path] = hash[path].compact if hash[path]
      hash
    end

    # Ensures that the keys and values in the hash conform to the specified rules.
    # @param hash [Hash] The hash to be validated.
    # @raise [ArgumentError] If the hash contains invalid keys or values.
    # @return [void]
    def self.validate_hash(hash)
      return unless hash

      hash.each do |key, value|
        raise ArgumentError, "Invalid key: '#{key}'. Keys must be lowercase and may include dashes." unless key.to_s.match?(/\A[a-z]+(-[a-z]+)*\z/)

        raise ArgumentError, "Invalid value for '#{key}': '#{value}'. Values must be a string, boolean, or number." unless [String, TrueClass, FalseClass, Numeric].any? { |type| value.is_a?(type) }
      end
    end
  end
end
