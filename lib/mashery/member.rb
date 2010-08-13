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

    def add_role(role_or_id)
      role_id = role_or_id.is_a?(Role) ? role_or_id.id : role_or_id
      Mashery.client.call_remote('member.addRole', {'username' => username}, {'id' => role_id})
    end

    def remove_role(role_or_id)
      role_id = role_or_id.is_a?(Role) ? role_or_id.id : role_or_id
      Mashery.client.call_remote('member.removeRole', {'username' => username}, {'id' => role_id})
    end
  end
end
