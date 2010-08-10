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
      run { ok(::Mashery.client.echo(value)) }
    end

  protected
    def run(&block)
      site_id = ENV['MASHERY_SITE_ID'] or
        raise Exception, "Please set the MASHERY_SITE_ID environment variable."
      key = ENV['MASHERY_API_KEY'] or
        raise Exception, "Please set the MASHERY_API_KEY environment variable."
      secret = ENV['MASHERY_SHARED_SECRET'] or
        raise Exception, "Please set the MASHERY_SHARED_SECRET environment variable."
      ::Mashery.client = ::Mashery::Client.new(site_id, key, secret)
      ::Mashery.logger.level = Logger::DEBUG
      begin
        yield
      rescue ::Mashery::JsonRpcException => e
        error(e.message)
      rescue ::Mashery::ValidationException => e
        e.errors.each {|err| warn("#{err['field']}: #{err['message']}")}
        error("Unable to execute method due to validation errors")
      end
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

    desc "create USERNAME DISPLAY_NAME EMAIL [--fields ...]", "Create a member"
    method_option :fields, :type => :hash
    def create(username, display_name, email)
      run do
        begin
          member = ::Mashery::Member.create(username, display_name, email, options[:fields])
          ok("Member #{member.username} created")
        rescue ::Mashery::DuplicateObjectException
          error("The username #{username} has already been claimed")
        end
      end
    end

    desc "fetch USERNAME", "Fetch a member"
    def fetch(username)
      run do
        member = ::Mashery::Member.fetch(username)
        if member
          ok("Member #{username} found")
          say(member.to_yaml)
        else
          warn("Member #{username} not found")
        end
      end
    end

    desc "addrole USERNAME ROLE_ID", "Assign a role to a member"
    def addrole(username, role_id)
      run do
        member = ::Mashery::Member.fetch(username)
        if member
          role = ::Mashery::Role.fetch(role_id.to_i)
          if role
            member.add_role(role)
            ok("Role #{role.name} assigned to member #{username}")
          else
            warn("Role #{role_id} not found")
          end
        else
          warn("Member #{username} not found")
        end
      end
    end

    desc "rmrole USERNAME ROLE_ID", "Revoke a role from a member"
    def rmrole(username, role_id)
      run do
        member = ::Mashery::Member.fetch(username)
        if member
          role = ::Mashery::Role.fetch(role_id.to_i)
          if role
            member.remove_role(role)
            ok("Role #{role.name} revoked from member #{username}")
          else
            warn("Role #{role_id} not found")
          end
        else
          warn("Member #{username} not found")
        end
      end
    end

    desc "delete USERNAME", "Delete a member"
    def delete(username)
      run do
        ::Mashery::Member.delete(username)
        ok("Member #{username} deleted")
      end
    end
  end

  class KeyCLI < CLI
    namespace 'mashery:key'

    desc "create SERVICE_KEY USERNAME [--fields ...]", "Create a key"
    method_option :fields, :type => :hash
    def create(service_key, username)
      run do
        key = ::Mashery::Key.create(service_key, username, options[:fields])
        ok("Key #{key.id} created for member #{username} and service #{service_key}")
      end
    end

    desc "fetch ID", "Fetch a key"
    def fetch(id)
      run do
        key = ::Mashery::Key.fetch(id.to_i)
        if key
          ok("Key #{id} found")
          say(key.to_yaml)
        else
          warn("Key #{id} not found")
        end
      end
    end

    desc "delete ID", "Delete a key"
    def delete(id)
      run do
        ::Mashery::Key.delete(id.to_i)
        ok("Key #{id} deleted")
      end
    end
  end

  class RoleCLI < CLI
    namespace 'mashery:role'

    desc "create NAME [--fields ...]", "Create a role"
    method_option :fields, :type => :hash
    def create(name)
      run do
        role = ::Mashery::Role.create(name, options[:fields])
        ok("Role #{role.id} created with name #{name}")
      end
    end

    desc "fetch ID", "Fetch a role"
    def fetch(id)
      run do
        role = ::Mashery::Role.fetch(id.to_i)
        if role
          ok("Role #{id} found")
          say(role.to_yaml)
        else
          warn("Role #{id} not found")
        end
      end
    end

    desc "delete ID", "Delete a role"
    def delete(id)
      run do
        ::Mashery::Role.delete(id.to_i)
        ok("Role #{id} deleted")
      end
    end
  end
end
