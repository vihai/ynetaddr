
module Netaddr

  class IPNet

    # Explicitly set the prefix. If any host bits are set, they will be reset to zero
    #
    # @param [Integer] p Integer host byte-order representation of the prefix
    # @return [Integer] the actual prefix set
    #
    def prefix=(p)
      @prefix = self.class.new(p).mask!(mask)
    end

    # @return the mask as host byte-ordering Integer
    #
    def mask
      @fullmask ^ (@fullmask >> @length)
    end

    # @return [Integer] the wildcard (mask bitwise negation) in host byte-ordering
    #
    def wildcard
      @fullmask >> @length
    end

    # @return [Range] a range of valid hosts in the network
    #
    # /31s and /32s for IPv4 and /127 and /128 for IPv6 are properly handled
    #
    def hosts
      host_min..host_max
    end

    # @return [IPAddr] the first usable host of this network
    #
    # /31s and /32s for IPv4 and /127 and /128 for IPv6 are properly handled
    #
    def host_min
      if @length >= @max_length - 1
        @prefix
      else
        @prefix + 1
      end
    end

    # @return [IPAddr] the last usable host of this network
    #
    # /31s and /32s for IPv4 and /127 and /128 for IPv6 are properly handled
    #
    def host_max
      if @length == @max_length
        @prefix
      elsif @length == @max_length - 1
        @prefix | wildcard
      else
        (@prefix | wildcard) - 1
      end
    end

    # @return [IPAddr] the network address of this network or nil if not applicable
    #
    def network
      return nil if @length >= @max_length - 1
      @prefix
    end

    # @return [Boolean] true if the specified IP address is contained in the network.
    #
    def include?(addr)
      addr = @address_class.new(addr) if !addr.kind_of?(@address_class)
      (addr & mask) == @prefix
    end

    # @return [String] a human-readable representation of the IPv6 network
    def inspect
      "#<%#{self.class.to_s}:#{to_s}>"
    end

    # @return [String] a string representation of the network address in address/plen format
    #
    def to_s
      "#{@prefix.to_s}/#{@length}"
    end

    # @return [Hash] a Hash with :prefix and :length keys respectively containing the Integer representation of interface's
    #                address and network mask length
    #
    def to_hash
      { :prefix => @prefix, :length => @length }
    end

    # @return [Boolean] true if both objects represent the same network
    #
    def ==(other)
      @prefix == other.prefix && @length == other.length
    end

    # @return [Boolean] true if specified network contains this network and does not coincide with it
    #
    def <(other)
      other = self.class.new(other) unless other.kind_of?(self.class)
      @length > other.length && ((@prefix & other.mask) == other.prefix)
    end

    # @return [Boolean] true if specified network is contained in this network and does not coincide with it
    #
    def >(other)
      other = self.class.new(other) unless other.kind_of?(self.class)
      @length < other.length && ((other.prefix & mask) == @prefix)
    end

    # @return [Boolean] true if specified network contains this network
    #
    def <=(other)
      other = self.class.new(other) unless other.kind_of?(self.class)
      @length >= other.length && ((@prefix & other.mask) == other.prefix)
    end

    # @return [Boolean] true if specified network is contained in this netwok
    #
    def >=(other)
      other = self.class.new(other) unless other.kind_of?(self.class)
      @length <= other.length && ((other.prefix & mask) == @prefix)
    end

    # @return [IPNet] a network enlarged by n bits, keeping the same prefix (resetting the host bytes)
    #
    def <<(n)
      self.class.new({ :prefix => @prefix, :length => cliplen(@length - n) })
    end

    # @return [IPNet] a network shrinked by n bits, keeping the same prefix (resetting the host bytes)
    #
    def >>(n)
      self.class.new({ :prefix => @prefix, :length => cliplen(@length + n) })
    end

    # Case comparison. If the object being matched is an IPv4/v6Addr return true if it is contained in the network
    #
    def ===(other)
      if other.kind_of?(@address_class)
        (other & mask) == @prefix
      else
        false
      end
    end

    private

    def cliplen(l)
      [[0, l].max, @max_length].min
    end

  end

end
