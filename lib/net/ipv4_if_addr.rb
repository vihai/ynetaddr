#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  # IPv4 Interface Address class
  #
  # This class embeds a prefix length into an IP address but it's not an IPv4 Network
  #
  class IPv4IfAddr < IPIfAddr

    attr_accessor :addr
    attr_accessor :length

    # Instantiates a new IPv4 Interface Address object
    #
    # @param addr Any supported IPv4 representation to initialize from:
    #             It may be an object responding to to_ipv4ifaddr, in Integer or an object responding to to_s
    #             It also accepts a hash with :addr and :length keys
    #
    #             Valid string representations are:
    #             a.b.c.d/nn
    #
    # Raises FormatNotRecognized if the representation isn't valid
    #
    def initialize(arg = '127.0.0.1/8')

      @fullmask = 0xffffffff
      @length = 32
      @max_length = 32
      @address_class = IPv4Addr
      @net_class = IPv4Net

      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if arg.respond_to?(:to_ipv4ifaddr)
        @addr = arg.to_ipv4ifaddr.addr
        @length = arg.to_ipv4ifaddr.length
      elsif arg.class.name == 'IPAddr' # avoids having to require ipaddr
        @addr = IPv4Addr.new(arg.to_i)
        @length = arg.prefix
      elsif arg.kind_of?(Hash)
        addr = arg.delete(:addr)
        addr_binary = arg.delete(:addr_binary)
        length = arg.delete(:length)
        mask = arg.delete(:mask)
        raise ArgumentError, "Unknown options #{arg.keys}" if arg.any?

        @addr = IPv4Addr.new(addr) if addr
        @addr = IPv4Addr.new(binary: addr_binary) if addr_binary

        @length = length if length
        @length = IPv4Net.mask_to_length(IPv4Addr.new(mask).to_i) if mask
      elsif arg.kind_of?(Integer)
        @addr = IPv4Addr.new(arg)
        @length = 32
      elsif arg.respond_to?(:to_s)
        addr = arg.to_s

        if addr =~ /^(.+)\/(.+)$/
          @addr = IPv4Addr.new($1)
          @length = $2.to_i
        else
          raise FormatNotRecognized, 'Format not recognized'
        end
      else
        raise FormatNotRecognized, "Cannot initialize from #{arg}"
      end

      raise InvalidAddress, "Length #{@length} less than zero" if @length < 0
      raise InvalidAddress, "Length #{@length} greater than #{@max_length}" if @length > @max_length
      raise InvalidAddress, 'Network address specified' if @length < 31 && @addr == network.prefix
      raise InvalidAddress, 'Broadcast address specified' if @length < 31 && @addr == network.broadcast
    end

    # @return [String] the dotted-quad representation of the mask
    #
    def mask_dotquad
      [mask].pack('N').unpack('C*').join('.')
    end

    # @return [String] the dotted-quad representation of the wildcard
    #
    def wildcard_dotquad
      [wildcard].pack('N').unpack('C*').join('.')
    end

    # @return [Symbol] the pre-CIDR IP class (see IPv4Addr).
    #
    def ipclass
      address.ipclass
    end

    # @return [Boolean] true if the IP address is in RFC1918 space
    #
    def is_rfc1918?
      address.is_rfc1918?
    end

    # @return [IPv4IfAddr] self
    #
    def to_ipv4ifaddr
      self
    end

    # @return [IPv4Addr] the interface's IPv4 address
    #
    def to_ipv4addr
      @addr
    end

    def ipv4?
      true
    end

    def ipv6?
      false
    end
  end
end
