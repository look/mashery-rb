module Mashery
  class Member < ApiObjectBase
    attr_reader :created, :updated
    attr_accessor :username, :email, :display_name, :uri, :blog, :im, :imsvc, :phone,
      :company, :address1, :address2, :locality, :region, :postal_code, :country_code, :first_name, :last_name,
      :registration_ipaddr, :area_status, :external_id, :passwd_new

    def self.create(username, display_name, email, fields = {})
      fields ||= {}
      our_fields = fields.merge('username' => username, 'display_name' => display_name, 'email' => email)
      super(our_fields)
    end
  end
end
