module Mashery
  class Exception < ::Exception
    def self.create(options = {})
      case options['code']
      when 1000 then ValidationException.new(options['data'])
      else JsonRpcException.new("#{options['message']} (JSON-RPC error #{options['code']})")
      end
    end
  end

  class JsonRpcException < Exception
  end

  class ValidationException < Exception
    attr_reader :errors
    def initialize(errs= {})
      @errors = errs
    end
  end
end