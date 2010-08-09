require 'rubygems'
require 'bundler'
Bundler.setup

# XXX: only do this when the task has not been installed
$: << 'lib'

require 'mashery'

module Mashery
  class CLI < Thor
    namespace :mashery

    desc "echo VALUE", "Echo the provided value (tests connectivity and authentication)"
    def echo(value)
      run do
        say ::Mashery::Client.new(@site_id, @key, @secret).echo(value)
      end
    end

  protected
    def run(&block)
      @site_id = ENV['MASHERY_SITE_ID'] or
        raise Exception, "Please set the MASHERY_SITE_ID environment variable."
      @key = ENV['MASHERY_API_KEY'] or
        raise Exception, "Please set the MASHERY_API_KEY environment variable."
      @secret = ENV['MASHERY_SHARED_SECRET'] or
        raise Exception, "Please set the MASHERY_SHARED_SECRET environment variable."
      begin
        yield
      rescue ::Mashery::JsonRpcException
        error(e.message)
      end
    end

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
