require 'active_support'
require 'json'
require 'httparty'
require 'md5'

module Mashery
  class Client
    cattr_accessor :test_mode, :instance_writer => false
    @@test_mode = true

    cattr_accessor :logger, :instance_writer => false
    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    TEST_HOST = 'api.sandbox.mashery.com'
    PRODUCTION_HOST= 'api.mashery.com'

    def initialize(site_id, key, secret)
      host = self.class.test_mode ? TEST_HOST : PRODUCTION_HOST
      @uri = "http://#{host}/v2/json-rpc/#{site_id}"
      @key = key
      @secret = secret
    end

    def echo(value)
      call_remote('test.echo', value)
    end

    def call_remote(method, *params)
      # all calls are synchronous, so id in request and response will always be 1
      logger.debug "method: #{method} params: #{params.inspect}" if logger
      req = ::JSON[{:version => '1.1', :method => method, :params => params, :id => 1}]
      response = HTTParty.post(signed_uri, :body => req)
      res = ::JSON[response.body]
      raise Exception.create(res['error']) if res.include?('error')
      res['result']
    end

  protected
    def signed_uri
      "#{@uri}?apikey=#{@key}&sig=#{MD5.new(@key + @secret + Time.now.to_i.to_s).hexdigest}"
    end
  end
end
