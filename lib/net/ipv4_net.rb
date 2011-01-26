
module Net

  # IPv4 Network class
  #
  class IPv4Net < IPNet

    MASK = 0xffffffff

    def self.summarize(list)
      list.map! do |x|
        case x
        when IPv4Net ; x
        when IPv4Addr ; IPv4Net.new(:prefix => x, :length => 32)
        else x =~ /\// ? IPv4Net.new(x) : IPv4Net.new(:prefix => x, :length => 32)
        end
      end

      list
    end


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
    # Raises ArgumentError if the representation isn't valid
    #
    def initialize(net = '127.0.0.1/8')
      # TODO implement all inet_aton formats with hex/octal and classful addresses

      @fullmask = MASK
      @max_length = 32
      @address_class = IPv4Addr

      if net.respond_to?(:to_ipv4net)
        @prefix = IPv4Addr.new(net.to_ipv4net.prefix)
        @length = net.to_ipv4net.length
      elsif net.kind_of?(Hash)
        @prefix = IPv4Addr.new(net[:prefix])
        @length = net[:length]
      elsif net.kind_of?(Integer)
        @prefix = IPv4Addr.new(net)
        @length = 32
      elsif net.respond_to?(:to_s)
        net = net.to_s

        if net =~ /^(.+)\/(.+)$/
          @prefix = IPv4Addr.new($1)
          @length = $2.to_i
        else
          raise ArgumentError, 'Format not recognized'
        end
      else
        raise "Cannot initialize from #{net}"
      end

      @prefix.mask!(mask)
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

    # @return [String] the dotted-quad representation of the prefix
    #
    def prefix_dotquad
      [@prefix.to_i].pack('N').unpack('C*').join('.')
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
    # Raises an error if the network spans both unicast and multicast or reserved space
    #
    def unicast?
      [:a, :b, :c].include?(ipclass)
    end

    # @return [Boolean] true if the network is within the multicas address range
    #
    # Raises an error if the network spans both unicast and multicast space or reserved
    #
    def multicast?
      ipclass == :d
    end

    # @return [IPAddr] the network address of this network or nil if not applicable
    #
    def network
      return nil if @length >= @max_length - 1
      @prefix
    end

    # @return [IPAddr] the broadcast address of this network or nil if not applicable
    #
    def broadcast
      return nil if @length >= @max_length - 1
      @prefix | (@fullmask ^ mask)
    end

    # @return [String] the reverse-DNS name associated to the IP network. If the network is not byte-aligned
    #                  the output with contain the smaller aligned prefix.
    #
    def reverse
      [@prefix.to_i].pack('N').unpack('C*')[0...(@length / 8)].reverse.join('.') + '.in-addr.arpa'
    end

    # @return [Boolean] true if the network is wholly contained in RFC1918 space
    #
    def is_rfc1918?
      self <= '10.0.0.0/8' || self <= '172.16.0.0/12' || self <= '192.168.0.0/16'
    end

    # @return [IPv4Net] self
    #
    def to_ipv4net
      self
    end

    # @return [IPAddr] the first IP address in this network
    #
    def ip_min
      @prefix
    end

    # @return [IPAddr] the last IP address in this network
    #
    def ip_max
      @prefix | wildcard
    end

    # @return [IPAddr] the first usable host of this network
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
    # /31s and /32s are properly handled
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
  end
end
