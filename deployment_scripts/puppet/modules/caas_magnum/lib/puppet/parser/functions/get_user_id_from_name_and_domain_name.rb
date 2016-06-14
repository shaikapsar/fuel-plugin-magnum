module Puppet::Parser::Functions
  newfunction(:get_user_id_from_name_and_domain_name, :type => :rvalue,
:doc => <<-EOS
Returns the user id from name and domain name.
EOS
  ) do |arguments|

    require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..', '..',
                    'puppet', 'util', 'magnum'))

    raise(Puppet::ParseError, 'Argument order should be user_name, domain_name') if arguments.size != 2

    name              = arguments[0]
    domain_name       = arguments[1]

    return  Puppet::Util::Magnum.user_id_from_name_and_domain_name(name, domain_name)

  end
end

# vim: set ts=2 sw=2 et :
