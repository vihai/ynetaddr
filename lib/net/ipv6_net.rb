#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

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
    # Raises FormatNotRecognized if the representation isn't valid
    #
    def initialize(arg = '::/0')

      @fullmask = MASK
      @length = 128
      @max_length = 128
      @address_class = IPv6Addr
      @if_address_class = IPv6IfAddr

      if arg.respond_to?(:to_ipv6net)
        @prefix = IPv6Addr.new(arg.to_ipv6net.prefix)
        @length = arg.to_ipv6net.length

      elsif arg.class.name == 'IPAddr' # avoids having to require ipaddr
        @prefix = IPv6Addr.new(arg.to_i)
        @length = arg.prefix
      elsif arg.is_a?(IPv6Addr)
        @prefix = arg
        @length = 128
      elsif arg.kind_of?(Hash)
        prefix = arg.delete(:prefix)
        prefix_binary = arg.delete(:prefix_binary)
        length = arg.delete(:length)
        raise ArgumentError, "Unknown options #{arg.keys}" if arg.any?

        @prefix = IPv6Addr.new(prefix) if prefix
        @prefix = IPv6Addr.new(binary: prefix_binary) if prefix_binary
        @length = length if length

      elsif arg.kind_of?(Integer)
        @prefix = IPv6Addr.new(arg)
        @length = 128

      elsif arg.respond_to?(:to_s)
        net = arg.to_s

        if net =~ /^(.+)\/(.+)$/
          @length = $2.to_i
          @prefix = IPv6Addr.new($1)
        else
          raise FormatNotRecognized, 'Format not recognized'
        end
      else
        raise "Cannot initialize from #{arg}"
      end

      raise InvalidAddress, "Length #{@length} less than zero" if @length < 0
      raise InvalidAddress, "Length #{@length} greater than #{@max_length}" if @length > @max_length

      @prefix = @prefix.mask(mask)

      freeze
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
      !overlaps?('ff00::/8')
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

    # @return [IPAddr] the first IP of this network
    #
    def first_ip
      @prefix
    end

    # @return [IPAddr] the last IP of this network
    #
    def last_ip
      @prefix | wildcard
    end

    # @return [IPAddr] the first usable host of this network
    #
    def first_host
      @prefix
    end

    # @return [IPAddr] the last usable host of this network
    #
    def last_host
      @prefix | wildcard
    end

    def ipv4?
      false
    end

    def ipv6?
      true
    end
  end
end
