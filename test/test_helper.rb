# enconding: UTF-8

ENV['RACK_ENV'] = 'test'

# Coveralls coverage metrics.
require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/reporters'
require 'rack/test'
require 'rack/lobster'

require 'rack/domain'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
