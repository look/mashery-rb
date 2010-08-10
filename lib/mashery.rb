require 'mashery/exceptions'
require 'mashery/client'
require 'mashery/api_object_base'
require 'mashery/member'
require 'mashery/key'

module Mashery
  mattr_accessor :client
  @@client = nil

  mattr_accessor :logger, :instance_writer => false
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN

  mattr_accessor :test_mode, :instance_writer => false
  @@test_mode = true
end
