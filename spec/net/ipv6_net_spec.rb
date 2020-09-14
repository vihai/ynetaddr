#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv6Net do

describe 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    expect(IPv6Net.new('2a02:20:1:2::/64').prefix).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::/64').length).to eq(64)
  end

  require 'ipaddr'
  it 'accepts ::IPAddr' do
    expect(IPv6Net.new(::IPAddr.new('2a02:20:1:2::/64')).prefix.to_i).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new(::IPAddr.new('2a02:20:1:2::/64')).length).to eq(64)
  end

  it 'resets host bits' do
    expect(IPv6Net.new('2a02:20:1:2:3:4:5:6/32').prefix).to eq(0x2a020020000000000000000000000000)
  end

  it 'reject invalid empty address' do
    expect { IPv6Net.new('') }.to raise_error(ArgumentError)
  end

  it 'reject address without length' do
    expect { IPv6Net.new('2a02:20::') }.to raise_error(ArgumentError)
  end

  it 'reject address with slash but without length' do
    expect { IPv6Net.new('2a02:20::/') }.to raise_error(ArgumentError)
  end

  it 'reject address without prefix' do
    expect { IPv6Net.new('/64') }.to raise_error(ArgumentError)
  end

  it 'accepts a Hash with addr and mask keys with integer addr and length' do
    expect(IPv6Net.new(prefix_binary: 'AEIO1234567890XY', length: 128).prefix).to eq(0x4145494f313233343536373839305859)
    expect(IPv6Net.new(prefix_binary: 'AEIO1234567890XY', length: 128).length).to eq(128)
  end

  it 'raises ArgumentError if length > 32' do
    expect { IPv6Net.new(prefix: '2a02:20::', length: 129) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError if length < 0' do
    expect { IPv6Net.new(prefix: '2a02:20::', length: -1) }.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { IPv6Net.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end
end

describe :mask_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').mask_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a00::/8').mask_hex).to eq('ff00:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a02:20::/32').mask_hex).to eq('ffff:ffff:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a02:20::/127').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe')
    expect(IPv6Net.new('2a02:20::/128').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
  end
end

describe :wildcard_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').wildcard_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a00::/8').wildcard_hex).to eq('00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a02:20::/32').wildcard_hex).to eq('0000:0000:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a02:20::/127').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0001')
    expect(IPv6Net.new('2a02:20::/128').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
  end
end

describe :prefix_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').prefix_hex).to eq('::')
    expect(IPv6Net.new('2a00::/8').prefix_hex).to eq('2a00::')
    expect(IPv6Net.new('2a02:20::/32').prefix_hex).to eq('2a02:20::')
    expect(IPv6Net.new('2a02:20::/127').prefix_hex).to eq('2a02:20::')
    expect(IPv6Net.new('2a02:20::/128').prefix_hex).to eq('2a02:20::')
  end
end

describe :unicast? do
  it 'return false for multicast range' do
    expect(IPv6Net.new('f000::/4').unicast?).to be_falsey
    expect(IPv6Net.new('ff00::/8').unicast?).to be_falsey
    expect(IPv6Net.new('ff70::/9').unicast?).to be_falsey
    expect(IPv6Net.new('ffff::/16').unicast?).to be_falsey
  end

  it 'returns true for unicast range' do
    expect(IPv6Net.new('2a02:20::/32').unicast?).to be_truthy
  end
end

describe :multicast? do
  it 'returns true if network wholly multicast' do
    expect(IPv6Net.new('ff00::/8').multicast?).to be_truthy
    expect(IPv6Net.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/32').multicast?).to be_truthy
    expect(IPv6Net.new('ff7f:1:2:3::/96').multicast?).to be_truthy
  end

  it 'returns false if network wholly not multicast' do
    expect(IPv6Net.new('2a02::/32').multicast?).to be_falsey
    expect(IPv6Net.new('::/8').multicast?).to be_falsey
  end

  it 'returns false if network partially multicast' do
    expect(IPv6Net.new('f::/4').multicast?).to be_falsey
  end
end

describe :new_pb_multicast do
  it 'produces correct address' do
    expect(IPv6Net.new('2a02:20:1:2::5/64').new_pb_multicast(:global, 0x1234)).to eq('ff3e:40:2a02:20:1:2:0:1234')
  end
end

describe :reverse do
  it 'calculates the correct values' do
    expect(IPv6Net.new('::/0').reverse).to eq('.ip6.arpa')
    expect(IPv6Net.new('2a02:20:1:2::/64').reverse).to eq('2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa')
    expect(IPv6Net.new('2a02:20:1:2::5/128').reverse).to eq(
      '5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa')
  end
end


# parent class methods

describe :prefix= do
  it 'returns prefix' do
    expect((IPv6Net.new('2a02:20::/32').prefix = '2a02:30::')).to eq('2a02:30::')
  end

  it 'assigns prefix host bits' do
    a = IPv6Net.new('2a02:20::/32')
    a.prefix = '2a02:30::'
    expect(a).to eq(IPv6Net.new('2a02:30::/32'))
  end

  it 'resets host bits' do
    a = IPv6Net.new('2a02:20::/32')
    a.prefix = '2a02:30::44'
    expect(a).to eq(IPv6Net.new('2a02:30::/32'))
  end
end

describe :length= do
  it 'returns length' do
    expect((IPv6Net.new('2a02:20::/32').length = 16)).to eq(16)
  end

  it 'rejects invalid length' do
    expect { IPv6Net.new('2a02:20::/32').length = -1 }.to raise_error(ArgumentError)
    expect { IPv6Net.new('2a02:20::/32').length = 129 }.to raise_error(ArgumentError)
  end

  it 'resets host bits' do
    a = IPv6Net.new('2a02:20::/32')
    a.length = 16
    expect(a).to eq(IPv6Net.new('2a02::/16'))
  end
end

describe :mask do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').mask).to eq(0x00000000000000000000000000000000)
    expect(IPv6Net.new('2a00::/8').mask).to eq(0xff000000000000000000000000000000)
    expect(IPv6Net.new('2a02:20::/32').mask).to eq(0xffffffff000000000000000000000000)
    expect(IPv6Net.new('2a02:20::/127').mask).to eq(0xfffffffffffffffffffffffffffffffe)
    expect(IPv6Net.new('2a02:20::/128').mask).to eq(0xffffffffffffffffffffffffffffffff)
  end
end

describe :wildcard do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').wildcard).to eq(0xffffffffffffffffffffffffffffffff)
    expect(IPv6Net.new('2a00::/8').wildcard).to eq(0x00ffffffffffffffffffffffffffffff)
    expect(IPv6Net.new('2a02:20::/32').wildcard).to eq(0x00000000ffffffffffffffffffffffff)
    expect(IPv6Net.new('2a02:20::/127').wildcard).to eq(0x00000000000000000000000000000001)
    expect(IPv6Net.new('2a02:20::/128').wildcard).to eq(0x00000000000000000000000000000000)
  end
end

describe :addresses do
  it 'produces a range' do
    expect(IPv6Net.new('2a02:20:1:2::/64').addresses).to be_kind_of(Range)
  end

  it 'produces the correct range' do
    expect(IPv6Net.new('2a02:20:1:2::/64').addresses).to eq(
      IPv6Addr.new('2a02:20:1:2::0')..
      IPv6Addr.new('2a02:20:1:2:ffff:ffff:ffff:ffff'))
    expect(IPv6Net.new('2a02:20:1:2::1/127').addresses).to eq(
      IPv6Addr.new('2a02:20:1:2::0')..
      IPv6Addr.new('2a02:20:1:2::1'))
    expect(IPv6Net.new('2a02:20:1:2::1/128').addresses).to eq(
      IPv6Addr.new('2a02:20:1:2::1')..
      IPv6Addr.new('2a02:20:1:2::1'))
  end
end

describe :first_ip do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').first_ip).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::0/127').first_ip).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::1/128').first_ip).to eq(0x2a020020000100020000000000000001)
  end
end

describe :last_ip do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').last_ip).to eq(0x2a02002000010002ffffffffffffffff)
    expect(IPv6Net.new('2a02:20:1:2::0/127').last_ip).to eq(0x2a020020000100020000000000000001)
    expect(IPv6Net.new('2a02:20:1:2::1/128').last_ip).to eq(0x2a020020000100020000000000000001)
  end
end

describe :hosts do
  it 'produces a range' do
    expect(IPv6Net.new('2a02:20:1:2::/64').hosts).to be_kind_of(Range)
  end

  it 'produces the correct range' do
    expect(IPv6Net.new('2a02:20:1:2::/64').hosts).to eq(
      IPv6Addr.new('2a02:20:1:2::0')..
      IPv6Addr.new('2a02:20:1:2:ffff:ffff:ffff:ffff'))
    expect(IPv6Net.new('2a02:20:1:2::1/127').hosts).to eq(
      IPv6Addr.new('2a02:20:1:2::0')..
      IPv6Addr.new('2a02:20:1:2::1'))
    expect(IPv6Net.new('2a02:20:1:2::1/128').hosts).to eq(
      IPv6Addr.new('2a02:20:1:2::1')..
      IPv6Addr.new('2a02:20:1:2::1'))
  end
end

describe :first_host do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').first_host).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::0/127').first_host).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::1/128').first_host).to eq(0x2a020020000100020000000000000001)
  end
end

describe :last_host do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').last_host).to eq(0x2a02002000010002ffffffffffffffff)
    expect(IPv6Net.new('2a02:20:1:2::0/127').last_host).to eq(0x2a020020000100020000000000000001)
    expect(IPv6Net.new('2a02:20:1:2::1/128').last_host).to eq(0x2a020020000100020000000000000001)
  end
end

describe :include? do
  it 'matches correctly' do
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:19::0'))).to be_falsey
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20::0'))).to be_truthy
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20::1'))).to be_truthy
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20:ffff::1'))).to be_truthy
  end
end

describe :to_s do
  it 'produces correct output' do
    expect(IPv6Net.new('::/0').to_s).to eq('::/0')
    expect(IPv6Net.new('2a00::/8').to_s).to eq('2a00::/8')
    expect(IPv6Net.new('2aff::0/8').to_s).to eq('2a00::/8')
    expect(IPv6Net.new('2a02:20::/32').to_s).to eq('2a02:20::/32')
    expect(IPv6Net.new('2a02:20::/127').to_s).to eq('2a02:20::/127')
    expect(IPv6Net.new('2a02:20::/128').to_s).to eq('2a02:20::/128')
  end
end

describe 'to_hash' do
  it 'produces correct output' do
    expect(IPv6Net.new('2a02:20::/128').to_hash).to eq({ :prefix => '2a02:20::', :length => 128 })
  end
end

describe :== do
  it 'return true if networks are equal' do
    expect(IPv6Net.new('2a02:20::/32') == '2a02:20::/32').to be_truthy
  end

  it 'returns false if networks have different prefix' do
    expect(IPv6Net.new('2a02:20::/32') == '2a02:21::/32').to be_falsey
  end

  it 'returns false if networks have different prefix length' do
    expect(IPv6Net.new('2a02:20::/32') == '2a02:20::/31').to be_falsey
  end
end

describe :< do
  it 'is false for smaller networks' do
    expect(IPv6Net.new('2a02:20::/32') < IPv6Net.new('2a02:20::/33')).to be_falsey
  end

  it 'is false for equal-size networks' do
    expect(IPv6Net.new('2a02:20::/32') < IPv6Net.new('2a02:20::/32')).to be_falsey
  end

  it 'is false for non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') < IPv6Net.new('2a02:10::/31')).to be_falsey
  end

  it 'is true for networks bigger than us with same prefix' do
    expect(IPv6Net.new('2a02:20::/32') < IPv6Net.new('2a02:20::/31')).to be_truthy
  end

  it 'is true for networks bigger than us with different but contained prefix' do
    expect(IPv6Net.new('2a02:20::/32') < IPv6Net.new('2a02:21::/16')).to be_truthy
  end

  it 'is false for Ranges way smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20::ceef'))).to be_falsey
  end

  it 'is false for Ranges slightly smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:20::1')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:fffe'))).to be_falsey
  end

  it 'is true for Ranges way bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:10::')..IPv6Addr.new('2a02:20:20:30::'))).to be_truthy
  end

  it 'is true for Ranges slightly bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:1f:ffff:ffff:ffff:ffff')..IPv6Addr.new('2a02:20:20:21::'))).to be_truthy
  end

  it 'is false if the Range\'s first IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:20::')..IPv6Addr.new('2a02:20:20:21::'))).to be_falsey
  end

  it 'is false if the Range\'s last IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:20::128')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:ffff'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the left' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:1f::beef')..IPv6Addr.new('2a02:20:20:20::beef'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the right' do
    expect(IPv6Net.new('2a02:20:20:20::/64') < (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:21::beef'))).to be_falsey
  end
end

describe :<= do
  it 'is false for smaller networks' do
    expect(IPv6Net.new('2a02:20::/32') <= IPv6Net.new('2a02:20::/33')).to be_falsey
  end

  it 'is true for equal-size coincident networks' do
    expect(IPv6Net.new('2a02:20::/32') <= IPv6Net.new('2a02:20::/32')).to be_truthy
  end

  it 'is false for equal-size non-overlapping networks' do
    expect(IPv6Net.new('2a02:21::/32') <= IPv6Net.new('2a02:20::/32')).to be_falsey
  end

  it 'is false for non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') <= IPv6Net.new('2a02:10::/31')).to be_falsey
  end

  it 'is true for networks bigger than us with same prefix' do
    expect(IPv6Net.new('2a02:20::/32') <= IPv6Net.new('2a02:20::/31')).to be_truthy
  end

  it 'is true for networks bigger than us with different but contained prefix' do
    expect(IPv6Net.new('2a02:20::/32') <= IPv6Net.new('2a02:21::/16')).to be_truthy
  end

  it 'is false for Ranges way smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20::ceef'))).to be_falsey
  end

  it 'is false for Ranges slightly smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:20::1')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:fffe'))).to be_falsey
  end

  it 'is true for Ranges way bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:10::')..IPv6Addr.new('2a02:20:20:30::'))).to be_truthy
  end

  it 'is true for Ranges slightly bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:1f:ffff:ffff:ffff:ffff')..IPv6Addr.new('2a02:20:20:21::'))).to be_truthy
  end

  it 'is true if the Range\'s first IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:20::')..IPv6Addr.new('2a02:20:20:21::'))).to be_truthy
  end

  it 'is true if the Range\'s last IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:1f::beef')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:ffff'))).to be_truthy
  end

  it 'is false if the Range partially overlaps on the left' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:1f::beef')..IPv6Addr.new('2a02:20:20:20::beef'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the right' do
    expect(IPv6Net.new('2a02:20:20:20::/64') <= (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:21::beef'))).to be_falsey
  end
end

describe :> do
  it 'is false for smaller non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:30::/33')).to be_falsey
  end

  it 'is true for smaller contained networks' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:20:0::/33')).to be_truthy
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:20:1::/33')).to be_truthy
  end

  it 'is false for equal-size networks' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:20::/32')).to be_falsey
  end

  it 'is false for non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:10::/31')).to be_falsey
  end

  it 'is false for networks bigger than us with same prefix' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:20::/31')).to be_falsey
  end

  it 'is false for networks bigger than us with different but contained prefix' do
    expect(IPv6Net.new('2a02:20::/32') > IPv6Net.new('2a02:21::/16')).to be_falsey
  end

  it 'is true for Ranges way smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20::ceef'))).to be_truthy
  end

  it 'is true for Ranges slightly smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:20::1')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:fffe'))).to be_truthy
  end

  it 'is false for Ranges way bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:10::')..IPv6Addr.new('2a02:20:20:30::'))).to be_falsey
  end

  it 'is false for Ranges slightly bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:1f:ffff:ffff:ffff:ffff')..IPv6Addr.new('2a02:20:20:21::'))).to be_falsey
  end

  it 'is false if the Range\'s first IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:20::')..IPv6Addr.new('2a02:20:20:21::'))).to be_falsey
  end

  it 'is false if the Range\'s last IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:ffff'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the left' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:1f::beef')..IPv6Addr.new('2a02:20:20:20::beef'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the right' do
    expect(IPv6Net.new('2a02:20:20:20::/64') > (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:21::beef'))).to be_falsey
  end
end

describe :>= do
  it 'is false for smaller non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:30::/33')).to be_falsey
  end

  it 'is true for smaller contained networks' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:20:0::/33')).to be_truthy
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:20:1::/33')).to be_truthy
  end

  it 'is true for equal-size networks' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:20::/32')).to be_truthy
  end

  it 'is false for non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:10::/31')).to be_falsey
  end

  it 'is false for networks bigger than us with same prefix' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:20::/31')).to be_falsey
  end

  it 'is false for networks bigger than us with different but contained prefix' do
    expect(IPv6Net.new('2a02:20::/32') >= IPv6Net.new('2a02:21::/16')).to be_falsey
  end

  it 'is true for Ranges way smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20::ceef'))).to be_truthy
  end

  it 'is true for Ranges slightly smaller than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:20::1')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:fffe'))).to be_truthy
  end

  it 'is false for Ranges way bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:10::')..IPv6Addr.new('2a02:20:20:30::'))).to be_falsey
  end

  it 'is false for Ranges slightly bigger than the network' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:1f:ffff:ffff:ffff:ffff')..IPv6Addr.new('2a02:20:20:21::'))).to be_falsey
  end

  it 'is true if the Range\'s first IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:20::')..IPv6Addr.new('2a02:20:20:20::beef'))).to be_truthy
  end

  it 'is true if the Range\'s last IP is not strictly contained' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:20:ffff:ffff:ffff:ffff'))).to be_truthy
  end

  it 'is false if the Range partially overlaps on the left' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:1f::beef')..IPv6Addr.new('2a02:20:20:20::beef'))).to be_falsey
  end

  it 'is false if the Range partially overlaps on the right' do
    expect(IPv6Net.new('2a02:20:20:20::/64') >= (IPv6Addr.new('2a02:20:20:20::beef')..IPv6Addr.new('2a02:20:20:21::beef'))).to be_falsey
  end
end

describe :overlaps? do
  it 'is false for smaller non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02:30::/33')).to be_falsey
  end

  it 'is false for bigger non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02:30::/31')).to be_falsey
  end

  it 'is false for equal-size non-overlapping networks' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02:30::/32')).to be_falsey
  end

  it 'is true for same network' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02:20::/32')).to be_truthy
  end

  it 'is true for bigger network containing us' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02::/16')).to be_truthy
  end

  it 'is true for smaller network contained' do
    expect(IPv6Net.new('2a02:20::/32').overlaps?('2a02:20:1::/48')).to be_truthy
  end
end

describe :>> do
  it 'operates correctly' do
    expect(IPv6Net.new('2a02:20::/32') >> 1).to eq('2a02:20::/33')
  end
end

describe :<< do
  it 'operates correctly' do
    expect(IPv6Net.new('2a02:20::/32') << 1).to eq('2a02:20::/31')
    expect(IPv6Net.new('2a02:21::/32') << 1).to eq('2a02:20::/31')
  end
end

describe :=== do
  it 'returns true if other is an IPv6 address and is contained in this network' do
    expect(IPv6Net.new('2a02:20::/32') === IPv6Addr.new('2a02:20::1')).to be_truthy
  end

  it 'returns false if other is not IPv6 address' do
    expect(IPv6Net.new('2a02:20::/32') === 1234).to be_falsey
  end

  it 'returns false if other is not contained in this network' do
    expect(IPv6Net.new('2a02:20::/32') === IPv6Addr.new('2a02:ff::1')).to be_falsey
  end
end

describe :<=> do
  it 'returns 0 if networks are equal' do
    expect(IPv6Net.new('2a02:20::/32') <=> IPv6Net.new('2a02:20::/32')).to eq(0)
  end

  it 'returns -1 if networks have the same prefix length and prefix a < prefix b' do
    expect(IPv6Net.new('2a02:20::/32') <=> IPv6Net.new('2a02:30::/32')).to eq(-1)
  end

  it 'returns +1 if networks have the same prefix length and prefix a < prefix b' do
    expect(IPv6Net.new('2a02:20::/32') <=> IPv6Net.new('2a02:10::/32')).to eq(1)
  end

  it 'returns -1 if network a is smaller than network b' do
    expect(IPv6Net.new('2a02:20::/32') <=> IPv6Net.new('2a02:20::/31')).to eq(-1)
  end

  it 'returns +1 if network a is bigger than network b' do
    expect(IPv6Net.new('2a02:20::/32') <=> IPv6Net.new('2a02:20::/33')).to eq(1)
  end
end

describe :+ do
  it 'returns of type IPv6IfAddr' do
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') + 1).to be_an_instance_of(IPv6IfAddr)
  end

  it 'sums correctly' do
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') + 1).to eq('2a02:1234:abcd:0000::1/64')
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') + (-1)).to eq('2a02:1234:abcc:ffff:ffff:ffff:ffff:ffff/64')
  end
end

describe :- do
  it 'returns of type IPv6Addr' do
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') - 1).to be_an_instance_of(IPv6Addr)
  end

  it 'subtracts correctly' do
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') - 1).to eq('2a02:1234:abcc:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a02:1234:abcd:0000::/64') - (-1)).to eq('2a02:1234:abcd:0000::1')
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(IPv6Net.new('2a02:1234:abcd::/64').to_json).to eq('"2a02:1234:abcd::/64"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(IPv6Net.new('2a02:1234:abcd::/64').to_yaml).to eq("--- 2a02:1234:abcd::/64\n")
  end
end

describe :ipv4? do
  it 'returns false' do
    expect(IPv6Net.new('2a02:1234:abcd:0::/64').ipv4?).to be_falsey
  end
end

describe :ipv6? do
  it 'returns true' do
    expect(IPv6Net.new('2a02:1234:abcd:0::/64').ipv6?).to be_truthy
  end
end

end

end
