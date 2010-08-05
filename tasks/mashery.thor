require 'rubygems'
require 'bundler'
Bundler.setup

module Mashery
  class CLI < Thor
    namespace :mashery

    desc "hello", "Say hello"
    def hello
      say "Hello World!"
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
