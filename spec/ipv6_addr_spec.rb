
require File.expand_path('../../lib/netaddr', __FILE__)

describe Netaddr::IPv6Addr, 'constructor' do
  it 'accepts [hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh] format' do
    Netaddr::IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i.should == 0x2a021234abcd00009999ffffa90bbbbb
  end

  it 'accepts address with padding zeroes format' do
    Netaddr::IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_i.should == 0x0002002202222222000f00ff0fffffff
  end

  it 'accepts address without padding zeroes format' do
    Netaddr::IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_i.should == 0x0002002202222222000f00ff0fffffff
  end

  it 'accepts address with compressed zeroes' do
    Netaddr::IPv6Addr.new('[ffff::ffff]').to_i.should == 0xffff000000000000000000000000ffff
    Netaddr::IPv6Addr.new('[::]').to_i.should == 0x00000000000000000000000000000000
    Netaddr::IPv6Addr.new('[::1]').to_i.should == 0x00000000000000000000000000000001
    Netaddr::IPv6Addr.new('[1::]').to_i.should == 0x00010000000000000000000000000000
  end
end

describe Netaddr::IPv6Addr, :hton do
# TODO
end

describe Netaddr::IPv6Addr, :reverse do
# TODO
end

describe Netaddr::IPv6Addr, :unicast? do
# TODO
end

describe Netaddr::IPv6Addr, :new_multicast do
# TODO
end

describe Netaddr::IPv6Addr, :multicast? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_transient? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_well_known? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_prefix_based? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_embedded_rp? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_embedded_rp do
# TODO
end

describe Netaddr::IPv6Addr, 'multicast_scope' do
  it 'calculates correct value' do
    Netaddr::IPv6Addr.new('ff00:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :reserved
    Netaddr::IPv6Addr.new('ff01:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :interface_local
    Netaddr::IPv6Addr.new('ff02:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :link_local
    Netaddr::IPv6Addr.new('ff03:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :reserved
    Netaddr::IPv6Addr.new('fff4:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :admin_local
    Netaddr::IPv6Addr.new('fff5:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :site_local
    Netaddr::IPv6Addr.new('fff6:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ffa7:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ffa8:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :organization_local
    Netaddr::IPv6Addr.new('ffa9:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ff5a:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ff5b:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ff5c:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ff0d:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    Netaddr::IPv6Addr.new('ff0e:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :global
    Netaddr::IPv6Addr.new('ff0f:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :reserved
  end

  it 'raises an error for non-multicast address' do
    lambda { Netaddr::IPv6Addr.new('2a02::1').multicast_scope }.should raise_error(StandardError)
  end
end

describe Netaddr::IPv6Addr, :multicast_all_routers? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_all_nodes? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_solicited_node? do
# TODO
end

describe Netaddr::IPv6Addr, :multicast_source_specific? do
# TODO
end

describe Netaddr::IPv6Addr, :to_s do
  it 'outputs in RFC5952 canonical format' do
    Netaddr::IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').to_s.should == '2a02:1234:abcd:0:9999:ffff:a90b:bbbb'
    Netaddr::IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_s.should == '2a02:1234:abcd:0:9999:ffff:a90b:bbbb'
    Netaddr::IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_s.should == '2:22:222:2222:f:ff:fff:ffff'
    Netaddr::IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_s.should == '2:22:222:2222:f:ff:fff:ffff'
    Netaddr::IPv6Addr.new('[ffff::ffff]').to_s.should == 'ffff::ffff'
    Netaddr::IPv6Addr.new('[::]').to_s.should == '::'
    Netaddr::IPv6Addr.new('[::1]').to_s.should == '::1'
    Netaddr::IPv6Addr.new('[1::]').to_s.should == '1::'
    Netaddr::IPv6Addr.new('[::192.168.0.1]').to_s.should == '::c0a8:1'
    Netaddr::IPv6Addr.new('[::C0A8:0001]').to_s.should == '::c0a8:1'
    Netaddr::IPv6Addr.new('[::ffff:192.168.0.1]').to_s.should == '::ffff:192.168.0.1'
    Netaddr::IPv6Addr.new('[::ffff:C0A8:0001]').to_s.should == '::ffff:192.168.0.1'
  end

  it 'rejects invalid addresses' do
    lambda { Netaddr::IPv6Addr.new('') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('[]') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('[:::]') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('[::::]') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('[1::1::1]') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('foo') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('2a02::4fg0') }.should raise_error(ArgumentError)
    lambda { Netaddr::IPv6Addr.new('2a02::1/64') }.should raise_error(ArgumentError)
  end
end

# Parent-class methods

describe Netaddr::IPv6Addr, :included_in? do
#TODO
end

describe Netaddr::IPv6Addr, :succ do
#TODO
end

describe Netaddr::IPv6Addr, :== do
#TODO
end

describe Netaddr::IPv6Addr, :<=> do
#TODO
end

describe Netaddr::IPv6Addr, :+ do
#TODO
end

describe Netaddr::IPv6Addr, :- do
#TODO
end

describe Netaddr::IPv6Addr, :| do
#TODO
end

describe Netaddr::IPv6Addr, :& do
#TODO
end

describe Netaddr::IPv6Addr, :mask do
#TODO
end

describe Netaddr::IPv6Addr, :mask! do
#TODO
end

describe Netaddr::IPv6Addr, :to_i do
#TODO
end

describe Netaddr::IPv6Addr, :hash do
#TODO
end
