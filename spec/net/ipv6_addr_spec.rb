#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv6Addr do

describe 'constructor' do
  it 'accepts Integer format' do
    expect(IPv6Addr.new(0x2a021234abcd00009999ffffa90bbbbb).to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end

  it 'accepts [hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh] format' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end

  it 'accepts address with padding zeroes format' do
    expect(IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_i).to eq(0x0002002202222222000f00ff0fffffff)
  end

  it 'accepts address without padding zeroes format' do
    expect(IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_i).to eq(0x0002002202222222000f00ff0fffffff)
  end

  it 'accepts address with compressed zeroes' do
    expect(IPv6Addr.new('[ffff::ffff]').to_i).to eq(0xffff000000000000000000000000ffff)
    expect(IPv6Addr.new('[::]').to_i).to eq(0x00000000000000000000000000000000)
    expect(IPv6Addr.new('[::1]').to_i).to eq(0x00000000000000000000000000000001)
    expect(IPv6Addr.new('[1::]').to_i).to eq(0x00010000000000000000000000000000)
  end

  it 'accepts hash[:addr]' do
    expect(IPv6Addr.new(addr: '[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
    expect(IPv6Addr.new(addr: 0x2a021234abcd00009999ffffa90bbbbb).to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end

  it 'accepts hash[:binary]' do
    expect(IPv6Addr.new(binary: 'AEIO1234567890XY').to_i).to eq(0x4145494f313233343536373839305859)
  end

  require 'ipaddr'
  it 'accepts ::IPAddr' do
    expect(IPv4Addr.new(::IPAddr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end

  it 'rejects a wrong size binary addr' do
    expect { IPv6Addr.new(binary: 'AEIO1234567890X') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new(binary: 'AEIO1234567890XY>') }.to raise_error(ArgumentError)
  end

  it 'rejects invalid addresses' do
    expect { IPv6Addr.new('') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('[]') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('[:::]') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('[::::]') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('[1::1::1]') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('foo') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('2a02::4fg0') }.to raise_error(ArgumentError)
    expect { IPv6Addr.new('2a02::1/64') }.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { IPv6Addr.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end
end

describe :to_binary do
  it 'returns a binary string representation of the IP address' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_binary).to eq(
      "*\x02\x124\xAB\xCD\x00\x00\x99\x99\xFF\xFF\xA9\v\xBB\xBB".force_encoding(Encoding::ASCII_8BIT))
  end
end

describe :reverse do
  it 'produces correct output' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').reverse).to eq(
      'b.b.b.b.b.0.9.a.f.f.f.f.9.9.9.9.0.0.0.0.d.c.b.a.4.3.2.1.2.0.a.2.ip6.arpa')
  end
end

describe :unicast? do
  it 'has correct result' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').unicast?).to be_truthy
    expect(IPv6Addr.new('[::0]').unicast?).to be_falsey
    expect(IPv6Addr.new('[::1]').unicast?).to be_truthy
    expect(IPv6Addr.new('[ff00:1:2:3:4:5:6:7]').unicast?).to be_falsey
  end
end

describe :new_multicast do
  it 'produces an IPv6Addr' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0)).to be_an_instance_of(IPv6Addr)
  end

  it 'produces a multicast IPv6Addr' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0).multicast?).to be_truthy
  end

  it 'raises an error if group_id is bigger than available space' do
    expect { IPv6Addr.new_multicast(:global, false, false, false, 0x1ffff0000000000000000000000000000) }.to raise_error(ArgumentError)
  end

  it 'produces multicas address with correct scope' do
    expect(IPv6Addr.new_multicast(:interface_local, false, false, false, 1234).multicast_scope).to eq(:interface_local)
    expect(IPv6Addr.new_multicast(:link_local, false, false, false, 1234).multicast_scope).to eq(:link_local)
    expect(IPv6Addr.new_multicast(:admin_local, false, false, false, 1234).multicast_scope).to eq(:admin_local)
    expect(IPv6Addr.new_multicast(:site_local, false, false, false, 1234).multicast_scope).to eq(:site_local)
    expect(IPv6Addr.new_multicast(:organization_local, false, false, false, 1234).multicast_scope).to eq(:organization_local)
    expect(IPv6Addr.new_multicast(:global, false, false, false, 1234).multicast_scope).to eq(:global)
  end
end

describe :multicast? do
  it 'matches correctly' do
    expect(IPv6Addr.new('::').multicast?).to be_falsey
    expect(IPv6Addr.new('::1').multicast?).to be_falsey
    expect(IPv6Addr.new('2a02:20:bad:c0de:1:2:3:4').multicast?).to be_falsey
    expect(IPv6Addr.new('ff00:20:bad:c0de:1:2:3:4').multicast?).to be_truthy
    expect(IPv6Addr.new('ffff:ff:bad:c0de:1:2:3:4').multicast?).to be_truthy
    expect(IPv6Addr.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff').multicast?).to be_truthy
  end
end

describe :multicast_transient? do
  it 'matches correctly' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_transient?).to be_falsey
    expect(IPv6Addr.new_multicast(:global, true, false, false, 0).multicast_transient?).to be_truthy
  end
end

describe :multicast_well_known? do
  it 'matches correctly' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_well_known?).to be_truthy
    expect(IPv6Addr.new_multicast(:global, true, false, false, 0).multicast_well_known?).to be_falsey
  end
end

describe :multicast_prefix_based? do
  it 'matches correctly' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_prefix_based?).to be_falsey
    expect(IPv6Addr.new_multicast(:global, false, true, false, 0).multicast_prefix_based?).to be_truthy
  end
end

describe :multicast_embedded_rp? do
  it 'matches correctly' do
    expect(IPv6Addr.new_multicast(:global, false, false, false, 0).multicast_embedded_rp?).to be_falsey
    expect(IPv6Addr.new_multicast(:global, false, false, true, 0).multicast_embedded_rp?).to be_truthy
  end
end

describe :multicast_embedded_rp do
  it 'produces correct result' do
    expect(IPv6Addr.new('FF7e:b40:2001:DB8:BEEF:FEED::1234').multicast_embedded_rp).to eq('2001:DB8:BEEF:FEED::b')
    expect(IPv6Addr.new('FF7e:b20:2001:DB8::1234').multicast_embedded_rp).to eq('2001:DB8::b')
    expect(IPv6Addr.new('FF7e:b20:2001:DB8:DEAD::1234').multicast_embedded_rp).to eq('2001:DB8::b')
    expect(IPv6Addr.new('FF7e:b30:2001:DB8:BEEF::1234').multicast_embedded_rp).to eq('2001:DB8:BEEF::b')
  end
end

describe 'multicast_scope' do
  it 'calculates correct value' do
    expect(IPv6Addr.new('ff00:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:reserved)
    expect(IPv6Addr.new('ff01:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:interface_local)
    expect(IPv6Addr.new('ff02:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:link_local)
    expect(IPv6Addr.new('ff03:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:reserved)
    expect(IPv6Addr.new('fff4:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:admin_local)
    expect(IPv6Addr.new('fff5:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:site_local)
    expect(IPv6Addr.new('fff6:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ffa7:1234:5678:9abc:def0:1234:5678:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ffa8:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:organization_local)
    expect(IPv6Addr.new('ffa9:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ff5a:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ff5b:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ff5c:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ff0d:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:unassigned)
    expect(IPv6Addr.new('ff0e:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:global)
    expect(IPv6Addr.new('ff0f:def0:1234:5678:1234:5678:9abc:9abc').multicast_scope).to eq(:reserved)
  end

  it 'raises an error for non-multicast address' do
    expect { IPv6Addr.new('2a02::1').multicast_scope }.to raise_error(StandardError)
  end
end

describe :multicast_all_nodes? do
  it 'matches correctly' do
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_all_nodes?).to be_truthy
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_all_nodes?).to be_truthy
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_all_nodes?).to be_falsey
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_all_nodes?).to be_falsey
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_all_nodes?).to be_falsey
    expect(IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_all_nodes?).to be_falsey
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_all_nodes?).to be_falsey
  end
end

describe :multicast_all_routers? do
  it 'matches correctly' do
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_all_routers?).to be_falsey
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_all_routers?).to be_falsey
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_all_routers?).to be_falsey
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_all_routers?).to be_truthy
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_all_routers?).to be_truthy
    expect(IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_all_routers?).to be_truthy
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_all_routers?).to be_falsey
  end
end

describe :multicast_solicited_node? do
  it 'matches correctly' do
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:1').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:1').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:1').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff01:0:0:0:0:0:0:2').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff02:0:0:0:0:0:0:2').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff05:0:0:0:0:0:0:2').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff0e:0:0:0:0:0:0:2').multicast_solicited_node?).to be_falsey
    expect(IPv6Addr.new('ff02::1:ff12:3456').multicast_solicited_node?).to be_truthy
    expect(IPv6Addr.new('ff02::1:fe12:3456').multicast_solicited_node?).to be_falsey
  end
end

describe :multicast_solicited_node_id do
  it 'return correct node id' do
    expect(IPv6Addr.new('ff02::1:ff12:3456').multicast_solicited_node_id).to eq(0x123456)
  end

  it 'raises an error if not a multicast solcited node address' do
    expect { IPv6Addr.new('ff02::1:ef12:3456').multicast_solicited_node_id }.to raise_error(NotMulticastSolicitedAddress)
  end
end

describe :multicast_source_specific? do
  it 'matches correctly' do
    expect(IPv6Addr.new('ff0e0000000000000000000012345678').multicast_source_specific?).to be_falsey
    expect(IPv6Addr.new('ff3e0000000000000000000012345678').multicast_source_specific?).to be_truthy
  end
end

describe :to_s do
  it 'outputs in RFC5952 canonical format' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').to_s).to eq('2a02:1234:abcd:0:9999:ffff:a90b:bbbb')
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_s).to eq('2a02:1234:abcd:0:9999:ffff:a90b:bbbb')
    expect(IPv6Addr.new('[2:22:222:2222:f:ff:fff:ffff]').to_s).to eq('2:22:222:2222:f:ff:fff:ffff')
    expect(IPv6Addr.new('[0002:0022:0222:2222:000f:00ff:0fff:ffff]').to_s).to eq('2:22:222:2222:f:ff:fff:ffff')
    expect(IPv6Addr.new('[ffff::ffff]').to_s).to eq('ffff::ffff')
    expect(IPv6Addr.new('[::]').to_s).to eq('::')
    expect(IPv6Addr.new('[::1]').to_s).to eq('::1')
    expect(IPv6Addr.new('[1::]').to_s).to eq('1::')
    expect(IPv6Addr.new('[::192.168.0.1]').to_s).to eq('::c0a8:1')
    expect(IPv6Addr.new('[::C0A8:0001]').to_s).to eq('::c0a8:1')
    expect(IPv6Addr.new('[::ffff:192.168.0.1]').to_s).to eq('::ffff:192.168.0.1')
    expect(IPv6Addr.new('[::ffff:C0A8:0001]').to_s).to eq('::ffff:192.168.0.1')
    expect(IPv6Addr.new('[ff00::1]').to_s).to eq('ff00::1')
  end
end

# Parent-class methods

describe :included_in? do
  it 'matches correctly' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('2a02::/16')).to be_truthy
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('::/0')).to be_truthy
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').included_in?('2a03::/32')).to be_falsey
  end
end

describe :succ do
  it 'returns a IPv6Addr' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').succ).to be_an_instance_of(IPv6Addr)
  end

  it 'returns the successive IP address' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').succ).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')
  end
end

describe :next do
  it 'returns a IPv6Addr' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').next).to be_an_instance_of(IPv6Addr)
  end

  it 'returns the successive IP address' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').next).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')
  end
end

describe :== do
  it 'autconverts string other' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      '[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to be_truthy
  end

  it 'return true for equal addresses' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') ==
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbc]')).to be_falsey
  end
end

describe :eql? do
  it 'autconverts string other' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').eql?(
      '[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).to be_truthy
  end

  it 'return true for equal addresses' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').eql?(
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]'))).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').eql?(
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbc]'))).to be_falsey
  end
end

describe :<=> do
  it 'returns a kind of Integer' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]') <=>
      IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]')).to be_a_kind_of(Integer)
  end

  it 'compares correctly' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')).to eq(0)
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')).to eq(-1)
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') <=>
      IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbba')).to eq(1)
  end
end

describe :+ do
  it 'returns of type IPv6Addr' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + 1).to be_an_instance_of(IPv6Addr)
  end

  it 'sums correctly' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + 1).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') + (-1)).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbba')
  end
end

describe :- do
  it 'returns of type IPv6Addr' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - 1).to be_an_instance_of(IPv6Addr)
  end

  it 'subtracts Fixnum from address' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - 1).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbba')
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - (-1)).to eq('2a02:1234:abcd:0000:9999:ffff:a90b:bbbc')
  end

  it 'subtracts IPv6Addr giving the distance' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbb9')).to eq(2)
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')).to eq(0)
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') - IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbd')).to eq(-2)
  end
end

describe :| do
  it 'returns of type IPv6Addr' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') | 0x0000ffff).to be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') | 0x0000ffff).to eq(0x2a021234abcd00009999ffffa90bffff)
  end
end

describe :& do
  it 'returns of type IPv6Addr' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') & 0x0000ffff).to be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb') & 0x0000ffff).to eq(0xbbbb)
  end
end

describe :mask do
  it 'returns of type IPv6Addr' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').mask(0x0000ffff)).to be_an_instance_of(IPv6Addr)
  end

  it 'operates correctly'do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').mask(0x0000ffff)).to eq(0xbbbb)
  end
end

describe :mask! do
  it 'returns self' do
    a = IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')
    expect(a.mask!(0xffff0000)).to be_equal(a)
  end

  it 'masks correctly' do
    a = IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb')
    expect(a.to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
    a.mask!(0xffff0000)
    expect(a.to_i).to eq(0xa90b0000)
  end
end

describe :to_i do
  it 'returns a kind of Integer' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').to_i).to be_a_kind_of(Integer)
  end

  it 'converts to integer' do
    expect(IPv6Addr.new('::0').to_i).to eq(0)
    expect(IPv6Addr.new('::').to_i).to eq(0)
    expect(IPv6Addr.new('::1').to_i).to eq(1)
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').to_i).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end
end

describe :hash do
  it 'returns a kind of Integer' do
    expect(IPv6Addr.new('[2a02:1234:abcd:0000:9999:ffff:a90b:bbbb]').hash).to be_a_kind_of(Integer)
  end

  it 'produces a hash' do
    expect(IPv6Addr.new('2a02:1234:abcd:0000:9999:ffff:a90b:bbbb').hash).to eq(0x2a021234abcd00009999ffffa90bbbbb)
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(IPv6Addr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb').to_json).to eq('"2a02:1234:abcd:0:9999:ffff:a90b:bbbb"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(IPv6Addr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb').to_yaml).to eq("--- 2a02:1234:abcd:0:9999:ffff:a90b:bbbb\n")
  end
end

describe :ipv4? do
  it 'returns false' do
    expect(IPv6Addr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb').ipv4?).to be_falsey
  end
end

describe :ipv6? do
  it 'returns true' do
    expect(IPv6Addr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb').ipv6?).to be_truthy
  end
end

end

end
