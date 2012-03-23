
module Net

  class IPNet

    attr_reader :prefix
    attr_reader :length
    attr_reader :max_length

    # Automatically instantiate the correct network depending on the parsed string
    #
    # @return [IPv4Net, IPv6Net] the instantiated network
    #
    def self.new(*args)
      if self == IPNet
        begin
          IPv6Net.new(*args)
        rescue ArgumentError
          IPv4Net.new(*args)
        end
      else
        super
      end
    end

    # Explicitly set the prefix. If any host bits are set, they will be reset to zero
    #
    # @param [Integer, IPAddr] p Integer host byte-order representation of the prefix
    # @return [Integer] the actual prefix set
    #
    def prefix=(p)
      p = @address_class.new(p) if !p.kind_of?(@address_class)
      @prefix = p.mask(mask)
    end

    # Explicitly set the prefix length. If any host bits are set, they will be reset to zero
    #
    # @param [Integer, IPAddr] l Integer new length
    # @return [Integer] the actual length set
    #
    def length=(l)
      raise 'Invalid prefix length' if l < 0 || l > @max_length

      @length = l
      @prefix = @prefix & mask
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

    # @return [Range] a range of IP addresses in the network
    #
    def addresses
      first_ip..last_ip
    end

    # @return [Range] a range of valid hosts in the network
    #
    def hosts
      first_host..last_host
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
      return false if !other
      other = self.class.new(other) if !other.kind_of?(self.class)
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

    # @return [Boolean] true if the other network overlaps with us
    #
    def overlaps?(other)
      other = self.class.new(other) unless other.kind_of?(self.class)
      self <= other || self >= other
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
      other.kind_of?(@address_class) && (other & mask) == @prefix
    end

    # Used for sorting, bigger network is greater than small network, for equal-size networks order by prefix value
    #
    def <=>(other)
      self.length == other.length ? self.prefix <=> other.prefix : other.length <=> self.length
    end

    private

    def cliplen(l)
      [[0, l].max, @max_length].min
    end

  end

end
