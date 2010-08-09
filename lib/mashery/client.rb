require 'active_support'
require 'httparty'
require 'md5'

module Mashery
  class Client
    @@test_mode = true
    def self.test_mode?
      @@test_mode
    end
    def self.test_mode=(flag)
      @@test_mode = flag
    end

    TEST_HOST = 'api.sandbox.mashery.com'
    PRODUCTION_HOST= 'api.mashery.com'

    def initialize(site_id, key, secret)
      host = self.class.test_mode?? TEST_HOST : PRODUCTION_HOST
      @uri = "http://#{host}/v2/json-rpc/#{site_id}"
      @key = key
      @secret = secret
    end

    def echo(value)
      call_remote('test.echo', value)
    end

    def call_remote(method, *params)
      # all calls are synchronous, so id in request and response will always be 1
#      puts "method: #{method} params: #{params.inspect}"
      req = ActiveSupport::JSON.encode({:version => '1.1', :method => method, :params => params, :id => 1})
      response = HTTParty.post(signed_uri, :body => req)
      res = ActiveSupport::JSON.decode(response.body)
      raise Exception.create(res['error']) if res.include?('error')
      res['result']
    end

  protected
    def signed_uri
      "#{@uri}?apikey=#{@key}&sig=#{MD5.new(@key + @secret + Time.now.to_i.to_s).hexdigest}"
    end
  end
end
