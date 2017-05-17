#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  # Implements IEEE 802 MAC-address class with arithmetic and utility methods
  #
  class MacAddr

    class BadArithmetic < StandardError ; end

    include Comparable

    # Instantiates a new MacAddr object
    #
    # @param addr A MAC-address representation to initialize from
    #             It may be an object responding to to_macaddr, an Integer or an object responding to to_s
    #             Valid string formats are:
    #             hhhh.hhhh.hhhh
    #             hh:hh:hh:hh:hh:hh
    #             hhhhhhhhhhhh
    #
    # Raises ArgumentError if the format is not supported
    #
    def initialize(addr = '0000:0000:0000')

      if addr.respond_to?(:to_macaddr)
        @addr = addr.to_macaddr.raw_addr
      elsif addr.kind_of?(Integer)
        @addr = addr
      elsif addr.respond_to?(:to_s)

        addr = addr.to_s.downcase

        raise ArgumentError, 'Invalid characters found' if addr =~ /[^0-9a-z:.]/

        addr = addr.to_s.tr('^[0-9a-f]', '')

        raise ArgumentError, 'Wrong size' if addr.length != 12

        # From hex to Fixnum/Bignum
        @addr = addr.split('').inject(0) { |a,v| a << 4 | v.hex }
      else
        raise "Cannot initialize from #{addr}"
      end
    end

    # Returns true if the address is unicast
    #
    # @return [Boolean] true if the address is unicast
    #
    def unicast?
      (@addr & 0x010000000000) == 0
    end

    # Returns true if the address is multicast
    #
    # @return [Boolean] true if the address is multicast
    #
    def multicast?
      (@addr & 0x010000000000) != 0 && !broadcast?
    end

    # Returns true if the address is broadcast
    #
    # @return [Boolean] true if the address is broadcast
    #
    def broadcast?
      @addr == 0xffffffffffff
    end

    # Returns true if the address is locally administered
    #
    # @return [Boolean] true if the address is locally administered
    #
    def locally_administered?
      (@addr & 0x020000000000) == 0
    end

    # Returns true if the address is globally unique
    #
    # @return [Boolean] true if the address is globally unique
    #
    def globally_unique?
      (@addr & 0x020000000000) != 0
    end

    # Returns the OUI part of the address
    #
    # @return [Integer] OUI part of the address
    #
    def oui
      (@addr & 0xfcffff000000) >> 24
    end

    # Returns the NIC part of the address
    #
    # @return [Integer] NIC part of the address
    #
    def nic
      @addr & 0x000000ffffff
    end

    # Compares the address
    #
    # @return [Boolean] true if the address matches
    #
    def ==(other)
      return false if !other
      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr == other.to_i
    end

    alias eql? ==
    alias === ==

    def <=>(other)
      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr <=> other.to_i
    end

    # Calculates new MAC-address with NIC value incremented by n
    #
    # @return [MacAddr] incremented object
    #
    def +(n)
      raise BadArithmetic if (self.nic + n) > 0xffffff
      MacAddr.new(@addr + n)
    end

    # Calculates new MAC-address with NIC value subtracted of n
    #
    # @return [MacAddr] subtracted object
    #
    def -(n)
      raise BadArithmetic if (self.nic - n) < 0
      MacAddr.new(@addr - n)
    end

    # @return [MacAddr] the object itself
    #
    def to_macaddr
      self
    end

    # @return [Integer] the integer representation of the MAC-address
    #
    def to_i
      @addr
    end

    # @return [String] the colon separated octet representation of the MAC-address
    #
    # Example: "00:12:34:56:78:9a"
    #
    def to_s
     ('%012x' % @addr).scan(/../).join(':')
    end

    # @return [String] the dot separated 2-octet representation of the MAC-address as used in Cisco IOS
    #
    # Example: "0012.3456.789a"
    #
    def to_s_cisco
      ('%012x' % @addr).scan(/..../).join('.')
    end

    # @return [String] the dash separated octet representation of the MAC-address
    #
    # Example: "00-12-34-56-78-9a"
    #
    def to_s_dash
      ('%012x' % @addr).scan(/../).join('-')
    end

    # @return [String] hexadecimal contiguous representation of the MAC-address
    #
    # Example: "00123456789a"
    #
    def to_s_plain
     '%012x' % @addr
    end

    # @return [String] the dash separated octet representation of the MAC-address
    #
    # Example: "00-12-34-56-78-9a"
    #
    def to_oid
      (0..5).inject([]) { |m, t| m.push((@addr >> (40 - (8 * t))) & 0xff ) }.join('.')
    end

    # @return [String] a string containing a human-readable representation of the MAC-address
    #
    # Example: "#<MacAddr:00:12:34:56:78:9a>"
    #
    def inspect
      "#<%MacAddr:#{to_s}>"
    end

    # @return [Integer] a hash of the valued to be used as key in hashes
    #
    def hash
      @addr
    end

    protected

    # Gets the successive value by finding next NIC value
    # Raises BadArithmetic if the increment would change the OUI
    #
    # @return [MacAddr] new MacAddr with incremented NIC value
    #
    def succ
      raise BadArithmetic if self.nic == 0xffffff
      MacAddr.new(@addr + 1)
    end

  end
end
