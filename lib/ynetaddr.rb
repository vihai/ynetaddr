require 'net/addr/version'

module Net
  class FormatNotRecognized < ArgumentError ; end
  class InvalidAddress < ArgumentError ; end
end

require 'net/mac_addr'
require 'net/mac_addr_64'

require 'net/ip_addr'
require 'net/ip_net'
require 'net/ip_if_addr'

require 'net/ipv4_addr'
require 'net/ipv4_net'
require 'net/ipv4_if_addr'

require 'net/ipv6_addr'
require 'net/ipv6_net'
require 'net/ipv6_if_addr'

require 'net/ip_tree'

require 'net/well_known'
