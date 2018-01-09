$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest-ci' if ENV['CI']

require 'neo/sdk'
