#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'net/ipv4_net'

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
    # Raises FormatNotRecognized if the representation isn't valid
    #
    def initialize(arg = nil, addr: nil, binary: nil, **args)

      @net_class = IPv4Net

      if arg
        if arg.kind_of?(Integer)
          @addr = arg
        elsif arg.respond_to?(:to_ipv4addr)
          @addr = arg.to_ipv4addr.to_i
        elsif defined?(::IPAddr) && arg.kind_of?(::IPAddr)
          @addr = arg.to_i
        elsif arg.respond_to?(:to_s)
          init_from_string(arg.to_s, **args)
        else
          raise ArgumentError, "Cannot initialize from #{arg}"
        end
      else
        if addr
          initialize(addr, **args)
        elsif binary
          raise FormatNotRecognized, "Size not equal to 4 octets" if binary.length != 4

          @addr = binary.unpack('N').first
        else
          raise ArgumentError, 'Neither addr or binary specified'
        end
      end

      freeze
    end

    protected def parse_value(val, dec:, hex:, oct:)
      # This convoluted parsing formula ensures that disabled formats do raise an exception even if disabled

      (val.downcase.start_with?('0x') && (v=Integer(val, 16)) && hex && v) ||
      (val.start_with?('0') && (v=Integer(val, 8)) && oct && v) ||
      ((!val.start_with?('0') || val == '0') && (v=Integer(val, 10)) && dec && v) ||
      (raise ArgumentError)
    end

    protected def init_from_string(val,
        dotquad: true, dotquad_dec: true, dotquad_hex: true, dotquad_oct: true,
        sq_brackets: true,
        decimal: true,
        hexadecimal: true,
        octal: true
      )

      if sq_brackets
        # Remove square brackets
        val = $1 if val =~ /^\[(.*)\]$/
      end

      if val.empty?
        raise FormatNotRecognized, 'Empty address'

      elsif dotquad && (match = (/^(0x[0-9af]+|[0-9]+)\.(0x[0-9af]+|[0-9]+)\.(0x[0-9af]+|[0-9]+)\.(0x[0-9af]+|[0-9]+)$/i.match(val)))
        parts = match[1..4].map do |part|
          begin
            parse_value(part, dec: dotquad_dec, hex: dotquad_hex, oct: dotquad_oct)
          rescue ArgumentError
            raise FormatNotRecognized, "'#{val.inspect}': Cannot parse octet value '#{part.inspect}'"
          end
        end

        if parts.any? { |x| x > 0xff }
          raise FormatNotRecognized, "'#{val.inspect}': Octet value greater than 255"
        end

        @addr = (parts[0] << 24) +
                (parts[1] << 16) +
                (parts[2] << 8) +
                 parts[3]

      else
        begin
          @addr = parse_value(val, dec: decimal, hex: hexadecimal, oct: octal)
        rescue ArgumentError
          raise FormatNotRecognized, "'#{val.inspect}': Cannot parse"
        end

        raise FormatNotRecognized, "'#{val.inspect}': Integer value greater than 2^32" if @addr >= 2**32
        raise FormatNotRecognized, "'#{val.inspect}': Integer value less than zero" if @addr < 0
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

    NULL = IPv4Addr.new('0.0.0.0')
    BROADCAST = IPv4Addr.new('255.255.255.255')
  end
end
