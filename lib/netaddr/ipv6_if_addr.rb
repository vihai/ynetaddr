
module Netaddr

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
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(addr = '::1/128')

      @fullmask = 0xffffffffffffffffffffffffffffffff
      @max_length = 128
      @address_class = IPv6Addr
      @net_class = IPv6Net

      if addr.kind_of?(IPv6IfAddr)
        @addr = addr.addr
        @length = addr.length
      elsif addr.respond_to?(:to_ipv6ifaddr)
        @addr = addr.to_ipv6ifaddr.addr
        @length = addr.to_ipv6ifaddr.length
      elsif addr.kind_of?(Hash)
        @addr = IPv6Addr.new(addr[:addr])
        @length = addr[:length]
      elsif addr.kind_of?(Integer)
        @addr = IPv6Addr.new(addr)
        @length = 128
      elsif addr.respond_to?(:to_s)
        addr = addr.to_s

        if addr =~ /^(.+)\/(.+)$/
          @addr = IPv6Addr.new($1)
          @length = $2.to_i
        else
          raise ArgumentError, 'Format not recognized'
        end

        raise ArgumentError, 'Network address specified' if @length < @max_length - 1 && @addr == network.prefix
      else
        raise "Cannot initialize from #{addr}"
      end
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

  end
end
