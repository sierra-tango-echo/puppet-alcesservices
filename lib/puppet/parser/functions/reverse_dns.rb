require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:reverse_dns, :type => :rvalue) do |args|
    IPAddr.new(args[0]).mask(args[1]).reverse.split('.').collect {|x| x unless x == '0'}.compact.join('.')
  end
end
