# frozen_string_literal: true

ruby '3.2.2'

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'attr_encrypted', github: 'Zetatango/attr_encrypted'

# Specify your gem's dependencies in porky_lib.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'bundler-audit'
  gem 'codecov'
  gem 'factory_bot_rails'
  gem 'rake'
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'rubocop_runner'
  gem 'simplecov'
  gem 'sqlite3'
  gem 'timecop'
end
