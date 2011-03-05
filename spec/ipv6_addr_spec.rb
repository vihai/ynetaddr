
require 'ynetaddr'

module Net

describe IPv6Addr, 'constructor' do
  it 'accepts [hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh] format' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i.should == 0x2a021234abcd00009999ffffa90bbbbb
  end

  it 'accepts address with padding zeroes format' do
    IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_i.should == 0x0002002202222222000f00ff0fffffff
  end

  it 'accepts address without padding zeroes format' do
    IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_i.should == 0x0002002202222222000f00ff0fffffff
  end

  it 'accepts address with compressed zeroes' do
    IPv6Addr.new('[ffff::ffff]').to_i.should == 0xffff000000000000000000000000ffff
    IPv6Addr.new('[::]').to_i.should == 0x00000000000000000000000000000000
    IPv6Addr.new('[::1]').to_i.should == 0x00000000000000000000000000000001
    IPv6Addr.new('[1::]').to_i.should == 0x00010000000000000000000000000000
  end

  it 'rejects invalid addresses' do
    lambda { IPv6Addr.new('') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('[]') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('[:::]') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('[::::]') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('[1::1::1]') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('foo') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('2a02::4fg0') }.should raise_error(ArgumentError)
    lambda { IPv6Addr.new('2a02::1/64') }.should raise_error(ArgumentError)
  end
end

describe IPv6Addr, :hton do
# TODO
end

describe IPv6Addr, :reverse do
  it 'produces correct output' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').reverse.should ==
      'b.b.b.b.b.0.9.a.f.f.f.f.9.9.9.9.0.0.0.0.d.c.b.a.4.3.2.1.2.0.a.2.ip6.arpa'
  end
end

describe IPv6Addr, :unicast? do
  it 'has correct result' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').unicast?.should be_true
    IPv6Addr.new('[::0]').unicast?.should be_false
    IPv6Addr.new('[::1]').unicast?.should be_true
    IPv6Addr.new('[ff00:1:2:3:4:5:6:7]').unicast?.should be_false
  end
end

describe IPv6Addr, :new_multicast do
  it 'produces an IPv6Addr' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).should be_an_instance_of(IPv6Addr)
  end

  it 'produces a multicast IPv6Addr' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).multicast?.should be_true
  end

  it 'raises an error if group_id is bigger than available space' do
    lambda { IPv6Addr.new_multicast(:global, false, false, false, 0x1ffff0000000000000000000000000000) }.should raise_error
  end

  it 'produces multicas address with correct scope' do
    IPv6Addr.new_multicast(:interface_local, false, false, false, 1234).multicast_scope.should == :interface_local
    IPv6Addr.new_multicast(:link_local, false, false, false, 1234).multicast_scope.should == :link_local
    IPv6Addr.new_multicast(:admin_local, false, false, false, 1234).multicast_scope.should == :admin_local
    IPv6Addr.new_multicast(:site_local, false, false, false, 1234).multicast_scope.should == :site_local
    IPv6Addr.new_multicast(:organization_local, false, false, false, 1234).multicast_scope.should == :organization_local
    IPv6Addr.new_multicast(:global, false, false, false, 1234).multicast_scope.should == :global
  end
end

describe IPv6Addr, :multicast? do
  it 'matches correctly' do
    IPv6Addr.new('::').multicast?.should be_false
    IPv6Addr.new('::1').multicast?.should be_false
    IPv6Addr.new('2a02:20:bad:c0de:1:2:3:4').multicast?.should be_false
    IPv6Addr.new('ff00:20:bad:c0de:1:2:3:4').multicast?.should be_true
    IPv6Addr.new('ffff:ff:bad:c0de:1:2:3:4').multicast?.should be_true
    IPv6Addr.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff').multicast?.should be_true
  end
end

describe IPv6Addr, :multicast_transient? do
  it 'matches correctly' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_transient?.should be_false
    IPv6Addr.new_multicast(:global, true, false, false, 0).multicast_transient?.should be_true
  end
end

describe IPv6Addr, :multicast_well_known? do
  it 'matches correctly' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_well_known?.should be_true
    IPv6Addr.new_multicast(:global, true, false, false, 0).multicast_well_known?.should be_false
  end
end

describe IPv6Addr, :multicast_prefix_based? do
  it 'matches correctly' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_prefix_based?.should be_false
    IPv6Addr.new_multicast(:global, false, true, false, 0).multicast_prefix_based?.should be_true
  end
end

describe IPv6Addr, :multicast_embedded_rp? do
  it 'matches correctly' do
    IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_embedded_rp?.should be_false
    IPv6Addr.new_multicast(:global, false, false, true, 0).multicast_embedded_rp?.should be_true
  end
end

describe IPv6Addr, :multicast_embedded_rp do
  it 'produces correct result' do
    IPv6Addr.new('FF7e:b40:2001:DB8:BEEF:FEED::1234').multicast_embedded_rp.should == '2001:DB8:BEEF:FEED::b'
    IPv6Addr.new('FF7e:b20:2001:DB8::1234').multicast_embedded_rp.should == '2001:DB8::b'
    IPv6Addr.new('FF7e:b20:2001:DB8:DEAD::1234').multicast_embedded_rp.should == '2001:DB8::b'
    IPv6Addr.new('FF7e:b30:2001:DB8:BEEF::1234').multicast_embedded_rp.should == '2001:DB8:BEEF::b'
  end
end

describe IPv6Addr, 'multicast_scope' do
  it 'calculates correct value' do
    IPv6Addr.new('ff00:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :reserved
    IPv6Addr.new('ff01:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :interface_local
    IPv6Addr.new('ff02:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :link_local
    IPv6Addr.new('ff03:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :reserved
    IPv6Addr.new('fff4:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :admin_local
    IPv6Addr.new('fff5:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :site_local
    IPv6Addr.new('fff6:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ffa7:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ffa8:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :organization_local
    IPv6Addr.new('ffa9:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ff5a:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ff5b:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ff5c:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ff0d:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :unassigned
    IPv6Addr.new('ff0e:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :global
    IPv6Addr.new('ff0f:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope.should == :reserved
  end

  it 'raises an error for non-multicast address' do
    lambda { IPv6Addr.new('2a02::1').multicast_scope }.should raise_error(StandardError)
  end
end

describe IPv6Addr, :multicast_all_nodes? do
  it 'matches correctly' do
    IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_all_nodes?.should be_true
    IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_all_nodes?.should be_true
    IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_all_nodes?.should be_false
    IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_all_nodes?.should be_false
    IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_all_nodes?.should be_false
    IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_all_nodes?.should be_false
    IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_all_nodes?.should be_false
  end
end

describe IPv6Addr, :multicast_all_routers? do
  it 'matches correctly' do
    IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_all_routers?.should be_false
    IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_all_routers?.should be_false
    IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_all_routers?.should be_false
    IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_all_routers?.should be_true
    IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_all_routers?.should be_true
    IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_all_routers?.should be_true
    IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_all_routers?.should be_false
  end
end

describe IPv6Addr, :multicast_solicited_node? do
  it 'matches correctly' do
    IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_solicited_node?.should be_false
    IPv6Addr.new('ff02::1:ff12:3456').multicast_solicited_node?.should be_true
    IPv6Addr.new('ff02::1:fe12:3456').multicast_solicited_node?.should be_false
  end
end

describe IPv6Addr, :multicast_solicited_node_id do
  it 'return correct node id' do
    IPv6Addr.new('ff02::1:ff12:3456').multicast_solicited_node_id.should == 0x123456
  end

  it 'raises an error if not a multicast solcited node address' do
    lambda { IPv6Addr.new('ff02::1:ef12:3456').multicast_solicited_node_id }.should raise_error
  end
end

describe IPv6Addr, :multicast_source_specific? do
  it 'matches correctly' do
    IPv6Addr.new('ff0e0000000000000000000012345678').multicast_source_specific?.should be_false
    IPv6Addr.new('ff3e0000000000000000000012345678').multicast_source_specific?.should be_true
  end
end

describe IPv6Addr, :to_s do
  it 'outputs in RFC5952 canonical format' do
    IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').to_s.should == '2a02:1234:abcd:0:9999:ffff:a90b:bbbb'
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_s.should == '2a02:1234:abcd:0:9999:ffff:a90b:bbbb'
    IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_s.should == '2:22:222:2222:f:ff:fff:ffff'
    IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_s.should == '2:22:222:2222:f:ff:fff:ffff'
    IPv6Addr.new('[ffff::ffff]').to_s.should == 'ffff::ffff'
    IPv6Addr.new('[::]').to_s.should == '::'
    IPv6Addr.new('[::1]').to_s.should == '::1'
    IPv6Addr.new('[1::]').to_s.should == '1::'
    IPv6Addr.new('[::192.168.0.1]').to_s.should == '::c0a8:1'
    IPv6Addr.new('[::C0A8:0001]').to_s.should == '::c0a8:1'
    IPv6Addr.new('[::ffff:192.168.0.1]').to_s.should == '::ffff:192.168.0.1'
    IPv6Addr.new('[::ffff:C0A8:0001]').to_s.should == '::ffff:192.168.0.1'
    IPv6Addr.new('[ff00::1]').to_s.should == 'ff00::1'
  end
end

# Parent-class methods

describe IPv6Addr, :included_in? do
  it 'matches correctly' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('2a02::/16').should be_true
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('::/0').should be_true
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('2a03::/32').should be_false
  end
end

describe IPv6Addr, :succ do
  it 'returns a IPv6Addr' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').send(:succ).should be_an_instance_of(IPv6Addr)
  end

  it 'computes proper value' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').send(:succ).should == '2a02:1234:abcd:0000:9999:ffff:a90b:bbbc'
  end
end

describe IPv6Addr, :== do
  it 'autconverts string other' do
    (IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      '[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').should be_true
  end

  it 'return true for equal addresses' do
    (IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).should be_true
  end

  it 'return false for different adddresses' do
    (IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbc]')).should be_false
  end
end

describe IPv6Addr, :<=> do
  it 'returns a kind of Integer' do
    (IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') <=>
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).should be_a_kind_of(Integer)
  end

  it 'compares correctly' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')).should == 0
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')).should == -1
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbba')).should == 1
  end
end

describe IPv6Addr, :+ do
  it 'returns of type IPv6Addr' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + 1).should be_an_instance_of(IPv6Addr)
  end

  it 'sums correctly' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + 1) == '2a02:1234:abcd:0000:9999:ffff:a90b:bbbc'
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + (-1)) == '2a02:1234:abcd:0000:9999:ffff:a90b:bbba'
  end
end

describe IPv6Addr, :- do
  it 'returns of type IPv6Addr' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - 1).should be_an_instance_of(IPv6Addr)
  end

  it 'subtracts correctly' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - 1) == '2a02:1234:abcd:0000:9999:ffff:a90b:bbbc'
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - (-1)) == '2a02:1234:abcd:0000:9999:ffff:a90b:bbba'
  end
end

describe IPv6Addr, :| do
  it 'returns of type IPv6Addr' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') | 0x0000ffff).should be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') | 0x0000ffff).should == 0x2a021234abcd00009999ffffa90bffff
  end
end

describe IPv6Addr, :& do
  it 'returns of type IPv6Addr' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') & 0x0000ffff).should be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') & 0x0000ffff).should == 0xbbbb
  end
end

describe IPv6Addr, :mask do
  it 'returns of type IPv6Addr' do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').mask(0x0000ffff)).should be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    (IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').mask(0x0000ffff)).should == 0xbbbb
  end
end

describe IPv6Addr, :mask! do
  it 'returns self' do
    a = IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')
    a.mask!(0xffff0000).should be_equal(a)
  end

  it 'masks correctly' do
    a = IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')
    a.to_i.should == 0x2a021234abcd00009999ffffa90bbbbb
    a.mask!(0xffff0000)
    a.to_i.should == 0xa90b0000
  end
end

describe IPv6Addr, :to_i do
  it 'returns a kind of Integer' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i.should be_a_kind_of(Integer)
  end

  it 'converts to integer' do
    IPv6Addr.new('::0').to_i.should == 0
    IPv6Addr.new('::').to_i.should == 0
    IPv6Addr.new('::1').to_i.should == 1
    IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').to_i.should == 0x2a021234abcd00009999ffffa90bbbbb
  end
end

describe IPv6Addr, :hash do
  it 'returns a kind of Integer' do
    IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').hash.should be_a_kind_of(Integer)
  end

  it 'produces a hash' do
    IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').hash.should == 0x2a021234abcd00009999ffffa90bbbbb
  end
end

end
