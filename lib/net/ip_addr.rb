#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  class IPAddr

    include Comparable

    # Automatically instantiate the correct network depending on the parsed string
    #
    # @return [IPv4Addr, IPv6Addr] the instantiated network
    #
    def self.new(*args)
      if self == IPAddr
        begin
          IPv6Addr.new(*args)
        rescue ArgumentError
          IPv4Addr.new(*args)
        end
      else
        super(*args)
      end
    end

    # @param [String, IPNet] net An IPNet or String representation of an IP network
    # @return [Boolean] true if the IP network includes this IP address
    #
    def included_in?(net)
      net = @net_class.new(net) if !net.kind_of?(@net_class)

      net.include?(self)
    end

    # Compare two IP addresses. This is used just to implement hosts enumeration since there is no real ordering
    #
    def <=>(other)
      return nil if other.nil?

      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr <=> other.to_i
    end

    # Sum n to the host part and return a new IPAddr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def +(n)
      self.class.new(@addr + n)
    end

    # Subtract n to the host part and return a new IPAddr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def -(n)
      if n.kind_of?(Integer)
        self.class.new(@addr - n)
      else
        n = self.class.new(n) if !n.kind_of?(self.class)
        @addr - n.to_i
      end
    end

    # Bitwise or
    #
    def |(n)
      self.class.new(@addr | n)
    end

    # Bitwise and
    #
    def &(n)
      self.class.new(@addr & n)
    end

    # Mask this address with the specified mask (equivalent to a bitwise and)
    #
    def mask(mask)
      self.class.new(@addr & mask)
    end

    # Mask this address with the specified mask (equivalent to a bitwise and) and set ourself with resulting value
    #
    def mask!(mask)
      @addr &= mask
      self
    end

    # @return [Integer] an integer (host-byte-order) representation of the IP address
    #
    def to_i
      @addr
    end

    # @return [String] a human-readable representation of the IP address
    #
    def inspect
      "#<%#{self.class.name}:#{to_s}>"
    end

    # @return [String] a JSON representation of the IP address which is usually the result of #to_s
    #
    def to_json(*args)
      "\"#{to_s}\""
    end

    # @return [String] a representation of the object for to_json
    #
    def as_json(*args)
      to_s
    end

    # @return [Integer] a hash value to use an IP address as a key
    #
    def hash
      @addr
    end

    alias eql? ==

    # @return [IPAddr] the "next" IP address while enumerating hosts in a network, needed for Range enumeration
    #
    def succ
      self.class.new(@addr + 1)
    end
    alias next succ

    # Returns a viable representation for encoders
    #
    def encode_with(coder)
      coder.scalar = to_s
      coder.tag = nil
    end
  end

end
