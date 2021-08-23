# frozen_string_literal: true
#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net
  class IPv4Addr < IPAddr
    NULL = IPv4Addr.new('0.0.0.0')
    LOOPBACK = IPv4Addr.new('127.0.0.1')
    BROADCAST = IPv4Addr.new('255.255.255.255')

    MC_ALL_HOSTS = IPv4Addr.new('224.0.0.1')
    MC_ALL_ROUTERS = IPv4Addr.new('224.0.0.2')
  end

  class IPv6Addr < IPAddr
    NULL = IPv6Addr.new('::')
    LOOPBACK = IPv6Addr.new('::1')

    MC_ALL_NODES = IPv6Addr.new('ff02::1')
    MC_ALL_ROUTERS = IPv6Addr.new('ff02::2')
  end

  class IPv6Net < IPNet
    DEFAULT = IPv6Net.new('::/0')
    LINK_LOCAL = IPv6Net.new('fe80::/10')
  end

  class IPv4Net < IPNet
    DEFAULT = IPv4Net.new('0.0.0.0/0')
    LOOPBACK = IPv4Net.new('127.0.0.0/8')
    LINK_LOCAL = IPv4Net.new('169.254.0.0/16')
    MULTICAST = IPv4Net.new('224.0.0.0/4')
  end
end
