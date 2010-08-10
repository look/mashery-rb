module Mashery
  class Role < ApiObjectBase
    attr_reader :id, :created, :updated, :is_assignable, :is_predefined
    attr_accessor :name, :description

    def assignable?
      is_assignable == true
    end

    def predefined?
      is_predefined == true
    end

    def self.create(name, fields = {})
      fields ||= {}
      our_fields = fields.merge('name' => name)
      super(our_fields)
    end
  end
end
