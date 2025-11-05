# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_support/all'
require 'active_model/naming'
require 'active_model/translation'
require 'redirect_safely'
require 'redirect_safely_validator'

require "active_support/testing/autorun"
