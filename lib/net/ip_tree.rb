
module Net

  class IPTreeNode

#    attr_accessor :parent
    attr_accessor :l
    attr_accessor :r
    attr_accessor :network
    attr_accessor :used

    def initialize(net)
      @used = used

      if net.kind_of?(IPNet)
        @network = net
      else
        begin
          @network = IPv6Net.new(net)
        rescue ArgumentError
          @network = IPv4Net.new(net)
        end
      end
    end

    def add(other)

      other = @network.class.new(other) unless other.kind_of?(@network.class)

      if other == @network
        @used = true
        return
      end

      if !(other < @network)
        raise 'Net not contained'
      end

      if (other.prefix.to_i & (1 << (@network.max_length - (@network.length + 1))) == 0)
        if !@l
          @l = IPTreeNode.new(@network.class.new(
                 :prefix => @network.prefix,
                 :length => @network.length + 1))
        end

        @l.add(other)
      else
        if !@r
          @r = IPTreeNode.new(@network.class.new(
                 :prefix => @network.prefix | (1 << (@network.max_length - (@network.length + 1))),
                 :length => @network.length + 1))
        end

        @r.add(other)
      end
    end

    def free_space(max_length = 32)

      return [] if @network.length >= max_length

      res = []

      if @l
        res += @l.free_space(max_length)
      else
        res << @network.class.new(
                 :prefix => @network.prefix,
                 :length => @network.length + 1)
      end

      if @r
        res += @r.free_space(max_length)
      else
        res << @network.class.new(
                 :prefix => @network.prefix | (1 << (@network.max_length - (@network.length + 1))),
                 :length => @network.length + 1)
      end

      res
    end

    def pick(length)
      net = free_space(length).sort.first

      if net
        net = IPv4Net.new(:prefix => net.prefix, :length => length)
        add(net)
        net
      else
        nil
      end
    end

    def to_s(indent = 0)
      s = ''
      s << @l.to_s(indent + (@used ? 2 : 0)) if @l
      s << @r.to_s(indent + (@used ? 2 : 0)) if @r
      s = (' ' * indent) + @network.to_s + "\n" + s if @used
      s
    end
  end

end
