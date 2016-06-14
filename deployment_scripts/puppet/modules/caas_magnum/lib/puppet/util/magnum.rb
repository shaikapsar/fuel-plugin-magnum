# Since there's only one magnum type for now,
# this probably could have all gone in the provider file.
# But maybe this is good long-term.
require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'
class Puppet::Util::Magnum < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  DEFAULT_DOMAIN = 'Default'

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new


  def self.request(service, action, properties=nil)
    super
  end

  def self.default_domain
    DEFAULT_DOMAIN
  end

  def self.domain_id_from_name(name)
    unless @domain_hash_name
      list = request('domain', 'list')
      @domain_hash_name = Hash[list.collect{|domain| [domain[:name], domain[:id]]}]
    end
    unless @domain_hash_name.include?(name)
      id = request('domain', 'show', name)[:id]
      err("Could not find domain with name [#{name}]") unless id
      @domain_hash_name[name] = id
    end
    @domain_hash_name[name]
  end

  def self.user_id_from_name_and_domain_name(name, domain_name)
    @users_name ||= {}
    id_str = "#{name}_#{domain_name}"
    unless @users_name.keys.include?(id_str)
      user = fetch_user(name, domain_name)
      err("Could not find user with name [#{name}] and domain [#{domain_name}]") unless user
      @users_name[id_str] = user[:id]
    end
    @users_name[id_str]
  end

  def self.fetch_user(name, domain)
    domain ||= default_domain
    request('user', 'show', [name, '--domain', domain])
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No user with a name or ID/
  end

end
