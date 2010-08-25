module Mashery
  class Query
    OBJECT_TYPES = ['members', 'keys', 'services', 'roles']
    DEFAULT_QUERIES_PER_SECOND = 2

    attr_reader :object_type, :fields
    attr_accessor :page

    def initialize(object_type, options={})
      if !OBJECT_TYPES.include?(object_type)
        raise "Invalid object type. '#{object_type}' must be in #{OBJECT_TYPE.inspect}"
      end

      @object_type = object_type

      if options[:fields]
        @fields = options[:fields]
      else
        @fields = "*"
      end

      @where = options[:where]
      @page = options[:page]
    end

    def page_clause
      "PAGE #{@page}" if @page
    end

    def where_clause
      "WHERE #{@where}" if @where
    end

    def query_string
      "SELECT #{fields} FROM #{object_type} #{where_clause} #{page_clause}"
    end

    def execute
      Mashery.client.call_remote('object.query', query_string)
    end

    def items
      execute['items']
    end

    # Page through the results. Due heavy use of the API, this method
    # takes a qps parameter to control how often the API is called.
    def fetch_all(qps=DEFAULT_QUERIES_PER_SECOND)
      response = execute
      items = response['items']

      while response['current_page'] < response['total_pages']
        self.page = response['current_page'] + 1
        response = execute
        items = items + response['items']
        
        sleep(1.0/DEFAULT_QUERIES_PER_SECOND)
      end

      return items
    end
  end
end
