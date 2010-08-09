module Mashery
  class Key < ApiObjectBase
    attr_reader :id, :created, :updated, :service_key, :username, :limits
    attr_accessor :apikey, :status, :rate_limit_ceiling, :qps_limit_ceiling, :rate_limit_exempt, :qps_limit_exempt,
      :required_referer, :secret

    def self.create(client, service_key, username, fields = {})
      fields ||= {}
      our_fields = fields.merge('service' => {'service_key' => service_key}, 'member' => {'username' => username})
      super(client, our_fields)
    end

    def initialize(data)
      limits = data.delete('limits')
      @limits = limits.map {|l| Limit.new(l['period'], l['source'], l['ceiling'])} if limits
      super
    end
  end

  class Limit < Struct.new(:period, :source, :ceiling)
  end
end
