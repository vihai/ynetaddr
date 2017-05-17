
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
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(addr = '127.0.0.1/8')

      @fullmask = 0xffffffff
      @max_length = 32
      @address_class = IPv4Addr
      @net_class = IPv4Net

      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if addr.respond_to?(:to_ipv4ifaddr)
        @addr = addr.to_ipv4ifaddr.addr
        @length = addr.to_ipv4ifaddr.length
      elsif addr.kind_of?(Hash)
        @addr = IPv4Addr.new(addr[:addr])
        @length = addr[:length]
      elsif addr.kind_of?(Integer)
        @addr = IPv4Addr.new(addr)
        @length = 32
      elsif addr.respond_to?(:to_s)
        addr = addr.to_s

        if addr =~ /^(.+)\/(.+)$/
          @addr = IPv4Addr.new($1)
          @length = $2.to_i
        else
          raise ArgumentError, 'Format not recognized'
        end

        raise ArgumentError, 'Network address specified' if @length < 31 && @addr == network.prefix
        raise ArgumentError, 'Broadcast address specified' if @length < 31 && @addr == network.broadcast
      else
        raise "Cannot initialize from #{addr}"
      end
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

  end
end
