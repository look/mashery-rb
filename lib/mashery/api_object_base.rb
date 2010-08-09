module Mashery
  class ApiObjectBase
    def self.create(client, fields = {})
      new(client.call_remote(method('create'), fields))
    end

    def self.delete(client, pk)
      client.call_remote(method('delete'), pk)
    end

    def self.method(basename)
      "#{name.split(/\:\:/).last.downcase}.#{basename}"
    end
  end
end
