module Mashery
  class ApiObjectBase
    def self.create(fields = {})
      new(Mashery.client.call_remote(method('create'), fields))
    end

    def self.fetch(id)
      data = Mashery.client.call_remote(method('fetch'), id)
      data.nil?? nil : new(data)
    end

    def self.delete(id)
      Mashery.client.call_remote(method('delete'), id)
    end

    def self.method(basename)
      "#{name.split(/\:\:/).last.downcase}.#{basename}"
    end

    def initialize(data)
      data.each_pair {|k, v| instance_variable_set("@#{k}".to_sym, v)}
    end
  end
end
