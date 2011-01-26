
module Net

  # IPv6 Network class
  #
  class IPv6Net < IPNet

    MASK = 0xffffffffffffffffffffffffffffffff

    # Instantiates a new IPv6 network object
    #
    # @param net Any supported IPv6 representation to initialize from:
    #            It may be:
    #             * an object responding to to_ipv6net
    #             * A Hash with :prefix and :length keys
    #             * An Integer (host byte-ordering) representing a /32 prefix
    #             * An object responding to to_s
    #               Valid string representations are:
    #               * a.b.c.d/nn
    #
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(net = '::/0')

      @fullmask = MASK
      @max_length = 128
      @address_class = IPv6Addr

      if net.respond_to?(:to_ipv6net)
        @prefix = IPv6Addr.new(net.to_ipv6net.prefix)
        @length = net.to_ipv6net.length
      elsif net.kind_of?(Hash)
        @prefix = IPv6Addr.new(net[:prefix])
        @length = net[:length]
      elsif net.kind_of?(Integer)
        @prefix = IPv6Addr.new(net)
        @length = 128
      elsif net.respond_to?(:to_s)
        net = net.to_s

        if net =~ /^(.+)\/(.+)$/
          @length = $2.to_i
          @prefix = IPv6Addr.new($1)
        else
          raise ArgumentError, 'Format not recognized'
        end
      else
        raise "Cannot initialize from #{net}"
      end

      @prefix.mask!(mask)
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

    # @return [String] the 16-bit fields representation of the prefix
    #
    def prefix_hex
      @prefix.to_s
    end

    # @return [Boolean] true if the network covers only unicast range
    #
    # Raised an error if the network spans both unicast and multicast or reserved space
    # How should we treat ::0 and ::1 ?
    #
    def unicast?
      !overlaps('ff00::/8')
    end

    # @return [Boolean] true if the network is within the multicas address range
    #
    # Raised an error if the network spans both unicast and multicast space or reserved
    #
    def multicast?
      self <= 'ff00::/8'
    end

    # Build an prefix-based multicast address from this network
    #
    # @param [Symbol, Integer] scope is multicast scope (see {IPv6Addr#scope)
    # @param [Integer] group_id is the Group Id
    #
    # @return [IPv6Addr] the multicast address associated to this prefix
    #
    def new_pb_multicast(scope, group_id)
      raise ArgumentError, 'invalid group id' if (group_id & 0xffffffffffffffffffffffff00000000) != 0
      raise ArgumentError, 'cannot apply for prefixes longer than /64' if @length > 64

      mc = @length << 96
      mc |= (@prefix.to_i >> 64) << 32
      mc |= group_id

      IPv6Addr.new_multicast(scope, true, true, false, mc)
    end

    # @return [String] the reverse-DNS name associated to the IP network. If the network is not byte-aligned
    #                  the output with contain the smaller aligned prefix.
    #
    def reverse
      ('%032x' % @prefix).split('')[0...@length/4].reverse.join('.') + '.ip6.arpa'
    end

    # @return [IPv6Net] self
    #
    def to_ipv6net
      self
    end

    # @return [IPAddr] the first usable host of this network
    #
    def host_min
      @prefix
    end

    # @return [IPAddr] the last usable host of this network
    #
    def host_max
      @prefix | wildcard
    end
  end
end
