ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/reporters'
require 'rack/test'
require 'rack/lobster'

require 'rack/domain'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
