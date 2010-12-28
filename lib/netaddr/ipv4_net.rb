
module Netaddr

  # IPv4 Network class
  #
  class IPv4Net

    class InvalidFormat < StandardError ; end
    class InvalidMask < StandardError ; end

    attr_reader :prefix
    attr_accessor :length

    # Instantiates a new IPv4 network object
    #
    # @param net Any supported IPv4 representation to initialize from:
    #            It may be:
    #             * an object responding to to_ipv4net
    #             * A Hash with :prefix and :length keys
    #             * An Integer (host byte-ordering) representing a /32 prefix
    #             * An object responding to to_s
    #               Valid string representations are:
    #               * a.b.c.d/nn
    #
    # Raises InvalidFormat if the representation isn't valid
    #
    def initialize(net = '127.0.0.1/8')
      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if net.respond_to?(:to_ipv4net)
        @prefix = net.to_ipv4net.prefix
        @length = net.to_ipv4net.length
      elsif net.kind_of?(Hash)
        @prefix = net[:prefix]
        @length = net[:length]
      elsif net.kind_of?(Integer)
        @prefix = net
        @length = 32
      elsif net.respond_to?(:to_s)
        net = net.to_s

        if net =~ /^(.+)\/(.+)$/
          prefix = $1
          @length = $2.to_i
        else
          raise InvalidFormat
        end

        prefix_parts = prefix.split('.')

        raise InvalidFormat if prefix_parts.empty?
        raise InvalidMask if !(0..32).include?(@length)

        @prefix = prefix_parts.map { |c|
                    raise InvalidFormat unless c =~ /^\d+$/
                    raise InvalidFormat if c.to_i > 255 || c.to_i < 0
                  c.to_i }.pack('C*').unpack('N').first
      else
        raise "Cannot initialize from #{net}"
      end

      # Reset host bits
      @prefix = @prefix & mask
    end

    # Explicitly set the prefix. If any host bits are set, they will be reset to zero
    #
    # @param [Integer] p Integer host byte-order representation of the prefix
    # @return [Integer] the actual prefix set
    #
    def prefix=(p)
      # Reset host bits
      @prefix = p & mask
    end

    # @return the mask as host byte-ordering Integer
    #
    def mask
      0xffffffff ^ (0xffffffff >> @length)
    end

    # @return [String] the dotted-quad representation of the mask
    #
    def mask_dotquad
      [mask].pack('N').unpack('C*').join('.')
    end

    # @return [Integer] the wildcard (mask bitwise negation) in host byte-ordering
    #
    def wildcard
      0xffffffff >> @length
    end

    # @return [String] the dotted-quad representation of the wildcard
    #
    def wildcard_dotquad
      [wildcard].pack('N').unpack('C*').join('.')
    end

    # @return [Symbol] the pre-CIDR IP class to which the netork belongs.
    #
    # Raises an error if the network spans multiple classes
    #
    def ipclass
      if self < '240.0.0.0/4'
        :e
      elsif self < '224.0.0.0/4'
        :d
      elsif self < '192.0.0.0/3'
        :c
      elsif self < '128.0.0.0/2'
        :b
      elsif self < '0.0.0.0/1'
        :a
      else
        raise 'Network spans multiple classes'
      end
    end

    # @return [Boolean] true if the network covers only unicast range
    #
    # Raised an error if the network spans both unicast and multicast or reserved space
    #
    def unicast?
      [:a, :b, :c].include?(ipclass)
    end

    # @return [Boolean] true if the network is within the multicas address range
    #
    # Raised an error if the network spans both unicast and multicast space or reserved
    #
    def multicast?
      ipclass == :d
    end

    # @return [Range] a range of valid hosts in the network
    #
    # /31s and /32s are properly handled
    #
    def hosts
      IPv4Addr.new(host_min)..IPv4Addr.new(host_max)
    end

    # @return [IPv4Addr] the first usable host of this network
    #
    # /31s and /32s are properly handled
    #
    def host_min
      if @length >= 31
        IPv4Addr.new(@prefix)
      else
        IPv4Addr.new(@prefix + 1)
      end
    end

    # @return [IPv4Addr] the last usable host of this network
    #
    # /31s and /32s are properly handled
    #
    def host_max
      if @length == 32
        IPv4Addr.new(@prefix)
      elsif @length == 31
        IPv4Addr.new(@prefix | wildcard)
      else
        IPv4Addr.new((@prefix | wildcard) - 1)
      end
    end

    # @return [IPv4Addr] the network address of this network or nil if not applicable (to /31s and /32s)
    #
    def network
      return nil if @length >= 31
      IPv4Addr.new(@prefix)
    end

    # @return [IPv4Addr] the broadcast address of this network or nil if not applicable (to /31s and /32s)
    #
    def broadcast
      return nil if @length >= 31
      IPv4Addr.new(@prefix | (0xffffffff ^ mask))
    end

    # @return [String] the dotted-quad representation of the prefix
    #
    def prefix_dotquad
      [@prefix].pack('N').unpack('C*').join('.')
    end

    # @return [String] a human-readable representation of the IPv4 network
    def inspect
      "#<%IPv4Net:#{to_s}>"
    end

    # @return [String] the reverse-DNS name associated to the IP network. If the network is not byte-aligned
    #                  the output with contain the smaller aligned prefix.
    #
    def reverse
      [@prefix].pack('N').unpack('C*')[0...(@length / 8)].reverse.join('.') + '.in-addr.arpa'
    end

    # @return [Boolean] true if the network is wholly contained in RFC1918 space
    #
    def is_rfc1918?
      self <= '10.0.0.0/8' || self <= '172.16.0.0/12' || self <= '192.168.0.0/16'
    end

    # @return [Boolean] true if the specified IP address is contained in the network.
    #
    def include?(addr)
      addr = IPv4Addr.new(addr) if !addr.kind_of?(IPv4Addr)
      (addr.to_i & mask) == @prefix
    end

    # @return [IPv4Net] self
    #
    def to_ipv4net
      self
    end

    # @return [String] a string representation of the network address in the form a.b.c.d/nn
    #
    def to_s
      "#{prefix_dotquad}/#{@length}"
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
      other = IPv4Net.new(other) unless other.kind_of?(IPv4Net)
      @length > other.length && ((@prefix & other.mask) == other.prefix)
    end

    # @return [Boolean] true if specified network is contained in this network and does not coincide with it
    #
    def >(other)
      other = IPv4Net.new(other) unless other.kind_of?(IPv4Net)
      @length < other.length && ((other.prefix & mask) == @prefix)
    end

    # @return [Boolean] true if specified network contains this network
    #
    def <=(other)
      other = IPv4Net.new(other) unless other.kind_of?(IPv4Net)
      @length >= other.length && ((@prefix & other.mask) == other.prefix)
    end

    # @return [Boolean] true if specified network is contained in this netwok
    #
    def >=(other)
      other = IPv4Net.new(other) unless other.kind_of?(IPv4Net)
      @length <= other.length && ((other.prefix & mask) == @prefix)
    end

    # Case comparison. If the object being matched is an IPv4 return true if it is contained in the network
    #
    def ===(other)
      if other.kind_of?(IPv4Addr)
        (other.to_i & mask) == @prefix
      else
        false
      end
    end

    # @return [IPv4Net] a network enlarged by n bits, keeping the same prefix (resetting the host bytes)
    #
    def <<(n)
      IPv4Net.new({ :prefix => @prefix, :length => cliplen(@length - n) })
    end

    # @return [IPv4Net] a network shrinked by n bits, keeping the same prefix (resetting the host bytes)
    #
    def >>(n)
      IPv4Net.new({ :prefix => @prefix, :length => cliplen(@length + n) })
    end

    private

    def cliplen(l)
      [[0, l].max, 32].min
    end
  end
end
