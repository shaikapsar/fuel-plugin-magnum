module Puppet::Parser::Functions
  newfunction(:get_domain_id, :type => :rvalue,
:doc => <<-EOS
Returns the domain id from domain name
EOS
  ) do |arguments|

    require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..', '..',
                    'puppet', 'util', 'magnum'))

    raise(Puppet::ParseError, 'Argument order should be domain_name') if arguments.size != 1

    name              = arguments[0]

    return  Puppet::Util::Magnum.domain_id_from_name(name)

  end
end

# vim: set ts=2 sw=2 et :
