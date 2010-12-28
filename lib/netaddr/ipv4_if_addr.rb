
module Netaddr

  # IPv4 Interface Address class
  #
  # This class embeds a prefix length into an IP address but it's not an IPv4 Network
  #
  class IPv4IfAddr

    class InvalidFormat < StandardError ; end
    class InvalidAddress < StandardError ; end
    class InvalidMask < StandardError ; end

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
    # Raises InvalidFormat if the representation isn't valid
    #
    def initialize(addr = '127.0.0.1/8')
      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if addr.kind_of?(IPv4Net)
        @addr = addr.addr
        @length = addr.length
      elsif addr.respond_to?(:to_ipv4ifaddr)
        @addr = addr.to_ipv4ifaddr.addr
        @length = addr.to_ipv4ifaddr.length
      elsif addr.kind_of?(Hash)
        @addr = addr[:addr]
        @length = addr[:length]
      elsif addr.kind_of?(Integer)
        @addr = addr
        @length = 32
      elsif addr.respond_to?(:to_s)
        addr = addr.to_s

        if addr =~ /^(.+)\/(.+)$/
          @addr = $1
          @length = $2.to_i
        else
          raise InvalidFormat
        end

        parts = @addr.split('.')

        raise InvalidFormat if parts.empty?
        raise InvalidMask if !(0..32).include?(@length)

        @addr = parts.map { |c|
                    raise InvalidFormat unless c =~ /^\d+$/
                    raise InvalidFormat if c.to_i > 255 || c.to_i < 0
                  c.to_i }.pack('C*').unpack('N').first

        raise InvalidAddress if @length < 31 && (@addr == network.prefix || @addr == network.broadcast)
      else
        raise "Cannot initialize from #{addr}"
      end
    end

    # @return the IPv4 network containing the interface address
    #
    def network
      IPv4Net.new(:prefix => @addr & mask, :length => @length)
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

    # @return [IPv4Addr] an IPv4Addr object containing the IP address
    #
    def address
      to_ipv4addr
    end

    # @return [Boolean] true if the specified IP address is included in the same interface's network
    #
    def include?(addr)
      addr = IPv4Addr.new(addr) if !addr.kind_of?(IPv4Addr)
      (addr.to_i & mask) == @addr
    end

    # @return [Boolean] true if both objects represent the same interface address
    #
    def ==(other)
      other = IPv4IfAddr.new(other) if !other.kind_of?(IPv4IfAddr)
      @addr == other.addr && @length == other.length
    end

    # @return [IPv4IfAddr] self
    #
    def to_ipv4ifaddr
      self
    end

    # @return [String] a string representation of the interface address in the form a.b.c.d/nn
    #
    def to_s
      "#{address.to_s}/#{@length}"
    end

    # @return [IPv4Addr] the interface's IPv4 address
    #
    def to_ipv4addr
      IPv4Addr.new(@addr)
    end

    # @return [Hash] a Hash with :addr and :length keys respectively containing the Integer representation of interface's
    #                address and network mask length
    #
    def to_hash
      { :addr => @addr, :length => @length }
    end

    # @return [String] a human-readable representation of the object
    #
    def inspect
      "#<%IPv4IfAddr:#{to_s}>"
    end

  end
end
