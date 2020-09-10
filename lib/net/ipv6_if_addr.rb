#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  # IPv6 Interface Address class
  #
  # This class embeds a prefix length into an IP address but it's not an IPv6 Network
  #
  class IPv6IfAddr < IPIfAddr

    attr_accessor :addr
    attr_accessor :length

    # Instantiates a new IPv6 Interface Address object
    #
    # @param addr Any supported IPv6 representation to initialize from:
    #             It may be an object responding to to_ipv6ifaddr, in Integer or an object responding to to_s
    #             It also accepts a hash with :addr and :length keys
    #
    #             Valid string representations are:
    #             a.b.c.d/nn
    #
    # Raises FormatNotRecognized if the representation isn't valid
    #
    def initialize(arg = '::1/128')

      @fullmask = 0xffffffffffffffffffffffffffffffff
      @length = 128
      @max_length = 128
      @address_class = IPv6Addr
      @net_class = IPv6Net

      if arg.respond_to?(:to_ipv6ifaddr)
        @addr = arg.to_ipv6ifaddr.addr
        @length = arg.to_ipv6ifaddr.length

      elsif arg.class.name == 'IPAddr' # avoids having to require ipaddr
        @addr = IPv6Addr.new(arg.to_i)
        @length = arg.prefix
      elsif arg.kind_of?(Hash)
        addr = arg.delete(:addr)
        addr_binary = arg.delete(:addr_binary)
        length = arg.delete(:length)
        raise ArgumentError, "Unknown options #{arg.keys}" if arg.any?

        @addr = IPv6Addr.new(addr) if addr
        @addr = IPv6Addr.new(binary: addr_binary) if addr_binary
        @length = length if length

      elsif arg.kind_of?(Integer)
        @addr = IPv6Addr.new(arg)
        @length = 128

      elsif arg.respond_to?(:to_s)
        addr = arg.to_s

        if addr =~ /^(.+)\/(.+)$/
          @addr = IPv6Addr.new($1)
          @length = $2.to_i
        else
          raise FormatNotRecognized, 'Format not recognized'
        end

        raise InvalidAddress, 'Network address specified' if @length < @max_length - 1 && @addr == network.prefix
      else
        raise FormatNotRecognized, "Cannot initialize from #{arg}"
      end

      raise InvalidAddress, "Length #{@length} less than zero" if @length < 0
      raise InvalidAddress, "Length #{@length} greater than #{@max_length}" if @length > @max_length
    end

    # @return [String] the 16-bit fields representation of the mask. No compression or padding zero removal is applied.
    #
    def mask_hex
      ('%.32x' % mask).scan(/..../).join(':')
    end

    # @return [String] the 16-bit fields representation of the wildcard. No compression or padding zero removal is applied.
    #
    def wildcard_hex
      ('%.32x' % wildcard).scan(/..../).join(':')
    end

    # @return [IPv6IfAddr] self
    #
    def to_ipv6ifaddr
      self
    end

    # @return [IPv6Addr] the interface's IPv6 address
    #
    def to_ipv6addr
      @addr
    end

    # Build an embedded-rp multicast address from this RP interface address
    #
    # @param [Symbol, Integer] scope is multicast scope (see {IPv6Addr#scope)
    # @param [Integer] group_id is the Group Id
    #
    # @return [IPv6Addr] the multicast address associated to this RP
    #
    def embedded_rp_multicast(scope, group_id)
      raise ArgumentError, 'not enough zero bits in NIC id to produce a multicast address' if (nic_id & (MASK ^ 0xffff)) != 0
      raise ArgumentError, 'prefix length > 64' if @length > 64

      mc = (@addr & 0xffff) << 104
      mc |= @length << 96
      mc |= (network.to_i >> 64) << 32
      mc |= group_id

      IPv6Addr.new_multicast(scope, true, true, true, mc)
    end

    def ipv4?
      false
    end

    def ipv6?
      true
    end
  end
end
