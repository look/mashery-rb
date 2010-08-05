require 'rubygems'
require 'bundler'
Bundler.setup

# XXX: only do this when the task has not been installed
$: << 'lib'

require 'mashery'

module Mashery
  class CLI < Thor
    namespace :mashery

    desc "echo SITE_ID, KEY, SECRET, VALUE", "Echo the provided value (tests connectivity and authentication)"
    def echo(site_id, key, secret, value)
      say ::Mashery.new(site_id, key, secret).echo(value)
    rescue Exception => e
      error(e.message)
    end

  protected
    def warn
      say_status :WARN, msg, :yellow
    end

    def ok(msg)
      say_status :OK, msg
    end

    def error(msg)
      say_status :ERROR, msg, :red
    end

    def debug(msg)
      say_status :DEBUG, msg, :cyan
    end
  end
end
