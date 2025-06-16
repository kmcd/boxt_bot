$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "boxt_bot"

require "active_support/all"
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
