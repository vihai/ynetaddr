require 'net/addr/version'

require 'net/mac_addr'

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

module Net
  class FormatNotRecognized < ArgumentError ; end
  class InvalidAddress < ArgumentError ; end
end
