#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  # IPv4 Address class
  #
  class IPv4Addr < IPAddr

    # Instantiates a new IPv4 address object
    #
    # @param addr Any supported IPv4 representation to initialize from:
    #             It may be an object responding to to_ipv4addr, in Integer or an object responding to to_s
    #             Valid string representations are:
    #             [a.b.c.d]
    #             a.b.c.d
    #
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(arg = '127.0.0.1')

      @net_class = IPv4Net

      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if arg.respond_to?(:to_ipv4addr)
        @addr = arg.to_ipv4addr.to_i

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
          raise ArgumentError, "Size not equal to 4 octets" if binary.length != 4

          @addr = binary.unpack('N').first
        else
          raise ArgumentError, 'missing address'
        end

      elsif arg.respond_to?(:to_s)
        addr = arg.to_s

        # Remove square brackets
        addr = $1 if addr =~ /^\[(.*)\]$/i

        parts = addr.split('.')

        raise ArgumentError, 'Empty address' if parts.empty?

        @addr = parts.map { |c|
                    raise ArgumentError, 'Invalid digit' unless c =~ /^\d+$/
                    raise ArgumentError, 'Octet value invalid' if c.to_i > 255 || c.to_i < 0
                  c.to_i }.pack('C*').unpack('N').first
      else
        raise ArgumentError, "Cannot initialize from #{arg}"
      end
    end

    # @return [String] a network-byte-ordered representation of the IP address
    #
    def to_binary
      [@addr].pack('N')
    end

    # @return [String] the reverse-DNS name associated to the IP address
    #
    def reverse
      [@addr].pack('N').unpack('C*')[0..3].reverse.join('.') + '.in-addr.arpa'
    end

    # @return [Boolean] true if the IP address belongs to RFC1918 space
    #
    def is_rfc1918?
      included_in?('10.0.0.0/8') || included_in?('172.16.0.0/12') || included_in?('192.168.0.0/16')
    end

    # @return [Symbol] the legacy class of the IP address. Since classful addressing has been deprecated since 1993
    #                  the class information has interest only for class D (multicast) space
    #
    def ipclass
      if included_in?('240.0.0.0/4')
        :e
      elsif included_in?('224.0.0.0/4')
        :d
      elsif included_in?('192.0.0.0/3')
        :c
      elsif included_in?('128.0.0.0/2')
        :b
      elsif included_in?('0.0.0.0/1')
        :a
      else
        raise 'Wut?'
      end
    end

    # @return [Boolean] true if a unicast address
    #
    def unicast?
      [:a, :b, :c].include?(ipclass)
    end

    # @return [Boolean] true if address is in multicast range
    #
    def multicast?
      ipclass == :d
    end

    # @return [MacAddr] corresponding MAC address
    #
    # Idea got from Dustin Spinhirne's Netaddr gem
    def multicast_mac
      raise 'not a multicast address' if !multicast?

      MacAddr.new((@addr & 0x007fffff) | 0x01005e000000)
    end

    # Convert to IPv4Addr.
    # @return [IPv4Addr] self
    #
    def to_ipv4addr
      self
    end

    # @return [String] a canonical dottet-quad string representation of the IP address
    #
    def to_s
      [@addr].pack('N').unpack('C*').join '.'
    end

    # @return [String] a canonical dottet-quad string representation of the IP address between square brackets
    #
    def to_s_bracketed
      "[#{to_s}]"
    end

    def ipv4?
      true
    end

    def ipv6?
      false
    end
  end
end
