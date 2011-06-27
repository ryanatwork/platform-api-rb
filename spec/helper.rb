# enable SimpleCov
require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler/setup'
require 'granicus-platform-api'

RSpec.configure do |config|
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
