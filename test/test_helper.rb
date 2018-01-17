# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest-ci' if ENV['CI']

require 'neo/sdk'
