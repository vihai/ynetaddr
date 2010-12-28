
module Netaddr

  # IPv4 Address class
  #
  class IPv4Addr < IPAddr

    class InvalidFormat < StandardError ; end

    include Comparable

    # Instantiates a new IPv4 address object
    #
    # @param addr Any supported IPv4 representation to initialize from:
    #             It may be an object responding to to_ipv4addr, in Integer or an object responding to to_s
    #             Valid string representations are:
    #             [a.b.c.d]
    #             a.b.c.d
    #
    # Raises InvalidFormat if the representation isn't valid
    #
    def initialize(addr = '127.0.0.1')
      # TODO implement all inet_aton formats with hex/octal and classful addresses

      if addr.respond_to?(:to_ipv4addr)
        @addr = addr.to_ipv4addr.to_i
      elsif addr.kind_of?(Integer)
        @addr = addr
      elsif addr.respond_to?(:to_s)
        addr = addr.to_s
        # Remove square brackets
        addr = $1 if addr =~ /^\[(.*)\]$/i

        parts = addr.split('.')

        raise InvalidFormat if parts.empty?

        @addr = parts.map { |c|
                    raise InvalidFormat unless c =~ /^\d+$/
                    raise InvalidFormat if c.to_i > 255 || c.to_i < 0
                  c.to_i }.pack('C*').unpack('N').first
      else
        raise "Cannot initialize from #{addr}"
      end
    end

    # Converts a network byte-ordering Integer representation of an IP address in a host byte-ordering one
    #
    def self.ntoh(naddr)
      naddr.unpack('C4').join('.')
    end

    # @return [Integer] a network-byte-ordered Integer representation of the IP address
    #
    def hton
      [@addr].pack('N')
    end

    # Instantiate a new IPv4Addr from a network-byte-ordered integer
    #
    def self.new_ntoh(naddr)
      return IPv4Addr.new(ntoh(naddr))
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

    # @return [Boolean] true if the network covers only unicast range
    #
    # Raised an error if the network spans both unicast and multicast space
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

    # @param [String, IPv4Net] net An IPv4Net or String representation of an IPv4 network
    # @return [Boolean] true if the IPv4 network includes this IP address
    #
    def included_in?(net)
      net = IPv4Net.new(net) if !net.kind_of?(IPv4Net)

      net.include?(self)
    end

    # @return [IPv4Addr] the "next" IPv4 address while enumerating hosts in a network, needed to be Comparable
    #
    def succ
      IPv4Addr.new(@addr + 1)
    end

    # Compare two IPv4 addresses. The address may be compared to another IPv4Addr object or a string representation of it
    #
    # @return [Boolean] true if the IP addresses match.
    #
    def ==(other)
      other = IPv4Addr.new(other) if !other.kind_of?(IPv4Addr)
      @addr == other.to_i
    end

    alias eql? ==
    alias === ==

    # Compare two IPv4 addresses. This is used just to implement hosts enumeration since there is no real ordering
    #
    def <=>(other)
      other = IPv4Addr.new(other) if !other.kind_of?(IPv4Addr)
      @addr <=> other.to_i
    end

    # Sum n to the host part and return a new IPv4Addr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def +(n)
      IPv4Addr.new(@addr + n)
    end

    # Subtract n to the host part and return a new IPv4Addr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def -(n)
      IPv4Addr.new(@addr - n)
    end

    # Convert to IPv4Addr.
    # @return [IPv4Addr] self
    #
    def to_ipv4addr
      self
    end

    # @return [Integer] an integer (host-byte-order) representation of the IP address
    #
    def to_i
      @addr
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

    # @return [String] a human-readable representation of the IP address
    #
    def inspect
      "#<%IPv4:#{to_s}>"
    end

    # @return [Integer] a hash value to use an IP address as a key
    #
    def hash
      @addr
    end
  end
end
