# frozen_string_literal: true

require_relative "lib/logsnag/version"

Gem::Specification.new do |spec|
  spec.name = "logsnag-ruby"
  spec.version = LogSnag::VERSION
  spec.authors = ["Damon Bauer"]
  spec.email = ["damonbauer@protonmail.com"]

  spec.summary = "Unofficial LogSnag API client, written in Ruby."
  spec.homepage = "https://github.com/damonbauer/logsnag-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "false"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.add_dependency "httparty", "~> 0.21.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
