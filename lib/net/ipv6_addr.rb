#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  class NotMulticastAddress < StandardError ; end
  class NotMulticastSolicitedAddress < StandardError ; end

  # IPv6 Address class
  #
  class IPv6Addr < IPAddr

    SCOPE_SYMBOLS = {
       :interface_local     => 0x1,
       :link_local          => 0x2,
       :admin_local         => 0x4,
       :site_local          => 0x5,
       :organization_local  => 0x8,
       :global              => 0xe,
    }

    # Instantiates a new IPv6 address object
    #
    # @param addr Any supported IPv6 representation to initialize from:
    #             It may be an object responding to to_ipv6addr, in Integer or an object responding to to_s
    #             Valid string representations are:
    #             [aaaa:bbbb:cccc:dddd:eeee:ffff:gggg:hhhh]
    #             aaaa:bbbb:cccc:dddd:eeee:ffff:gggg:hhhh
    #             Leading zeros are supported
    #             :: compression is supported
    #             upper and lower case hex digit are supported
    #
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(arg = '::1')

      @net_class = IPv6Net

      if arg.respond_to?(:to_ipv6addr)
        @addr = arg.to_ipv6addr.to_i

      elsif arg.class.name == 'IPAddr' # avoids having to require ipaddr
        @addr = arg.to_i
      elsif arg.kind_of?(Integer)
        @addr = arg

      elsif arg.kind_of?(Hash)
        addr = arg.delete(:addr)
        binary = arg.delete(:binary)
        raise ArgumentError, "Unknown options #{arg.keys}" if arg.any?

        @addr = if addr
          initialize(addr)
        elsif binary
          raise ArgumentError, "Size not equal to 16 octets" if binary.length != 16

          @addr = binary.unpack('N4').inject(0) { |i, x| (i << 32) + x }
        else
          raise ArgumentError, 'missing address'
        end

      elsif arg.respond_to?(:to_s)
        addr = arg.to_s
        addr = $1 if addr =~ /^\[(.*)\]$/i

        case addr
        when ''
          raise ArgumentError, 'empty address'
        when /^::ffff:(\d+\.\d+\.\d+\.\d+)$/i
          @addr = IPv4Addr.new($1).to_i | 0xffff00000000
        when /^::(\d+\.\d+\.\d+\.\d+)$/i
          @addr = IPv4Addr.new($1).to_i
        when /[^0-9a-f:]/i
          raise ArgumentError, 'invalid character(s)'
        when /::.*::/
          raise ArgumentError, 'multiple zero compressions'
        when /:::/
          raise ArgumentError, 'invalid format'
        when /^(.*)::(.*)$/
          addr, right = $1, $2

          l = addr.split(':')
          r = right.split(':')
          rest = 8 - l.size - r.size

          @addr = (l + Array.new(rest, '0') + r).inject(0) { |i, s| i << 16 | s.hex }
        else
          @addr = addr.split(':').inject(0) { |i, s| i << 16 | s.hex }
        end
      else
        raise ArgumentError, "Cannot initialize from #{arg}"
      end
    end

    # @return [String] a network-byte-ordered representation of the IP address
    #
    def to_binary
      (0..7).map { |i| (@addr >> (112 - 16 * i)) & 0xffff }.pack('n8')
    end

    # @return [String] the reverse-DNS name associated to the IP address
    #
    def reverse
      ('%.32x' % @addr).reverse.gsub(/.(?!$)/, '\&.') + '.ip6.arpa'
    end

    # @return [Boolean] true if a unicast address (per RFC4291 Sec 2.3)
    #
    def unicast?
      self != '::' && !included_in?('ff00::/8')
    end

    # Build a multicast IPv6 address with specified characteristics
    #
    # @param [Integer, Symbol] scope         contains IPv6 multicast scope
    #                                        Accepted symbols are:
    #                                          :interface_local
    #                                          :link_local
    #                                          :admin_local
    #                                          :site_local
    #                                          :organization_local
    #                                          :global
    # @param [Boolean]         transient     defines if the multicast address transient or well-known?
    # @param [Boolean]         prefix_based  defines if the multicast address uses prefix-based allocation (RFC3306)
    # @param [Boolean]         embedded_rp   defines if the multicast address contains an embedded Rendezvois Point (RFC3956)
    # @return [IPv6Addr] the resulting multicast address
    #
    def self.new_multicast(scope, transient, prefix_based, embedded_rp, group_id)
      raise ArgumentError, 'invalid group id' if (group_id & 0xffff0000000000000000000000000000) != 0

      if scope.kind_of?(Symbol)
        raise ArgumentError, 'scope not recognized' if SCOPE_SYMBOLS[scope].nil?
        scope = SCOPE_SYMBOLS[scope]
      end

      mc = 0xff000000000000000000000000000000
      mc |= scope << 112
      mc |= (transient ? 1 : 0) << 116
      mc |= (prefix_based ? 1 : 0) << 117
      mc |= (embedded_rp ? 1 : 0) << 118
      mc |= group_id

      IPv6Addr.new(mc)
    end

    # Build a source-specifc multicast address (RFC3306 Sec. 6)
    #
    # @param [Integer, Symbol] scope is the multicast address scope (see {#new_multicast})
    def self.new_ss_multicast(scope, group_id)
      raise ArgumentError, 'invalid group id' if (group_id & 0xffffffffffffffffffffffff00000000) != 0
      new_multicast(scope, true, true, false, group_id)
    end

    # @return [Boolean] true if the address is in multicast range
    #
    def multicast?
      included_in?('ff00::/8')
    end

    # @return [Boolean] true if the transient (T) bit is set (RFC4291 Sec 2.7)
    #
    def multicast_transient?
      raise 'Not a multicast address' if !multicast?
      @addr[116] != 0
    end

    # @return [Boolean] true if the address is well-known (transient bit is not set) (RFC4291 Sec 2.7)
    #
    def multicast_well_known?
      !multicast_transient?
    end

    # @return [Boolean] true if the prefix-based (P) bit is set (RFC4291 Sec 2.7)
    #
    def multicast_prefix_based?
      raise 'Not a multicast address' if !multicast?
      @addr[117] != 0
    end

    # @return [Boolean] true if the embedded-rp (R) bit is set (RFC4291 Sec 2.7)
    #
    def multicast_embedded_rp?
      raise 'Not a multicast address' if !multicast?
      @addr[118] != 0
    end

    # Obtain the embedded RP in a multicast address
    #
    # @return [IPv6Addr] the embedded RP address
    #
    def multicast_embedded_rp
      raise 'Not a multicast address' if !multicast?
      raise 'Not an embedded-RP addredd' if !multicast_embedded_rp?

      riid = (@addr & (0xf << 104)) >> 104
      plen = (@addr & (0xff << 96)) >> 96
      prefix =  (@addr & (((1 << plen) - 1) << (32 + (64 - plen)))) << 32
      group_id = @addr & 0xffffffff

      IPv6Addr.new(prefix | riid)
    end

    # @return [Symbol] the multicast scope as a symbol
    #
    def multicast_scope
      raise 'Not a multicast address' if !multicast?
      case (@addr & (0xf << 112)) >> 112
      when 0x0; :reserved
      when 0x1; :interface_local
      when 0x2; :link_local
      when 0x3; :reserved
      when 0x4; :admin_local
      when 0x5; :site_local
      when 0x6; :unassigned
      when 0x7; :unassigned
      when 0x8; :organization_local
      when 0x9; :unassigned
      when 0xa; :unassigned
      when 0xb; :unassigned
      when 0xc; :unassigned
      when 0xd; :unassigned
      when 0xe; :global
      when 0xf; :reserved
      end
    end

    # @return [Boolean] true if the address is a multicast all-nodes well-known address (See RFC4291 Sec 2.7.1)
    #
    def multicast_all_nodes?
      self == 'ff01::1' || self == 'ff02::1'
    end

    # @return [Boolean] true if the address is a multicast all-routers well-known address (See RFC4291 Sec 2.7.1)
    #
    def multicast_all_routers?
      self == 'ff01::2' || self == 'ff02::2' || self == 'ff05::2'
    end

    # @return [Boolean] true if the address is a multicast solicited-node address (See RFC4291 Sec 2.7.1)
    #
    def multicast_solicited_node?
      included_in?('ff02::1:ff00:0000/104')
    end

    # @return [Integer] the host-id part of a multicast solicited-node address (See RFC4291 Sec 2.7.1)
    #
    def multicast_solicited_node_id
      raise NotMulticastSolicitedAddress, 'Not a multicast solicited node address' if !multicast_solicited_node?
      @addr & 0xffffff
    end

    # @return [Boolean] true if the address is a source-specific multicast address (See RFC4291 Sec 2.7.1)
    #
    def multicast_source_specific?
      raise NotMulticastAddress, 'Not a multicast address' if !multicast?
      (@addr & 0xfff0ffffffffffffffffffff00000000) == 0xff300000000000000000000000000000
    end

    # Convert to IPv6Addr.
    # @return [IPv6Addr] self
    #
    def to_ipv6addr
      self
    end

    # @return [String] a canonical RFC5952-compliant string representation of the IPv6 address
    #
    def to_s
      fields = (0..7).map { |i| (@addr & 0xffff << (i * 16)) >> (i * 16) }

      embedded_ipv4 = included_in?('::ffff:0:0/96')

      compress = best_compressible_range(fields, embedded_ipv4 ? 2 : 0)

      out = fields.map { |x| '%x' % x }

      if compress
        s = ''
        s << ':' if compress.first == 0
        s << ':' if compress.last == 8
        out[compress] = s
      end

      if embedded_ipv4
        out[0..1] = IPv4Addr.new(fields[1] << 16 | fields[0]).to_s
      end

      out.reverse.join(':')
    end

    def ipv4?
      false
    end

    def ipv6?
      true
    end

    protected

    # Find compressible 16-bit fields ranges
    #
    # @param [Array] fields contains the IPv6 address separated in 16-bit fields
    # @param [Integer] start tells where to start (counting from least-significant field) to look for compressible ranges
    # @return an array of ranges ordered by decreasing length
    #
    def compressible_ranges(fields, start)
      ranges = []

      i = start
      while i < 8 && fields[i] != 0 ; i += 1 ; end

      if i
        li = i

        while i < 8
          while i < 8 && fields[i] == 0 ; i += 1 ; end
          if i > li + 1
            ranges << (li...i)
          end

          while i < 8 && fields[i] != 0 ; i += 1 ; end

          li = i
        end
      end

      ranges.sort! { |a,b| b.count <=> a.count }
      ranges
    end

    # Find the best compressible range as by RFC5952, by picking the longest sequence or most significative if equal
    #
    # @param [Array] fields contains the IPv6 address separated in 16-bit fields
    # @param [Integer] start tells where to start (counting from least-significant field) to look for compressible ranges
    # @return [Range] the best range
    #
    def best_compressible_range(fields, start)
      cr = compressible_ranges(fields, start)

      if cr[0]
        if cr[1]
          if cr[0].count == cr[1].count
            compress = cr[0].first < cr[1].first ? cr[1] : cr[0]
          else
            compress = cr[0]
          end
        else
          compress = cr[0]
        end
      else
        compress = nil
      end
    end
  end
end
