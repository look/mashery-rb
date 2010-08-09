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
      run { ok(client.echo(value)) }
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
      rescue ::Mashery::JsonRpcException => e
        error(e.message)
      rescue ::Mashery::ValidationException => e
        e.errors.each {|err| warn("#{err['field']}: #{err['message']}")}
        error("Unable to execute method due to validation errors")
      end
    end

    def client
      ::Mashery::Client.new(@site_id, @key, @secret)
    end

    def warn(msg)
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

  class MemberCLI < CLI
    namespace 'mashery:member'

    desc "create --fields username:USERNAME display_name:'DISPLAY NAME' email:EMAIL [...]", "Create a member"
    method_option :fields, :type => :hash, :required => true
    def create
      run do
        member = ::Mashery::Member.create(client, options[:fields])
        ok("Member #{member.username} created")
#        debug(member.to_yaml)
      end
    end

    desc "fetch USERNAME", "Fetch a member"
    def fetch(username)
      run do
        member = ::Mashery::Member.fetch(client, username)
        if member
          ok("Member #{username} found")
          say(member.to_yaml)
        else
          warn("Member #{username} not found")
        end
      end
    end

    desc "delete USERNAME", "Delete a member"
    def delete(username)
      run do
        ::Mashery::Member.delete(client, username)
        ok("Member #{username} deleted")
      end
    end
  end
end
