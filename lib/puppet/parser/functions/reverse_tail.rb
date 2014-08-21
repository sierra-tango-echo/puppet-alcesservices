require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:reverse_tail, :type => :rvalue) do |args|
    begin
      dns=IPAddr.new(args[0]).mask(args[1]).reverse.split('.').collect {|x| x unless x == '0'}.compact.join('.')
      IPAddr.new(args[0]).reverse.sub(dns,'').gsub(/\.$/,'')
    rescue
      raise "Unable to reverse tail '#{args[0]}/#{args[1]}'"
    end
  end
end
