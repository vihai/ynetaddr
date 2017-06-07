
require 'ynetaddr'

module Net

describe IPv6Net, 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    expect(IPv6Net.new('2a02:20:1:2::/64').prefix).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::/64').length).to eq(64)
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
end

describe IPv6Net, :mask_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').mask_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a00::/8').mask_hex).to eq('ff00:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a02:20::/32').mask_hex).to eq('ffff:ffff:0000:0000:0000:0000:0000:0000')
    expect(IPv6Net.new('2a02:20::/127').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe')
    expect(IPv6Net.new('2a02:20::/128').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
  end
end

describe IPv6Net, :wildcard_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').wildcard_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a00::/8').wildcard_hex).to eq('00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a02:20::/32').wildcard_hex).to eq('0000:0000:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6Net.new('2a02:20::/127').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0001')
    expect(IPv6Net.new('2a02:20::/128').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
  end
end

describe IPv6Net, :prefix_hex do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').prefix_hex).to eq('::')
    expect(IPv6Net.new('2a00::/8').prefix_hex).to eq('2a00::')
    expect(IPv6Net.new('2a02:20::/32').prefix_hex).to eq('2a02:20::')
    expect(IPv6Net.new('2a02:20::/127').prefix_hex).to eq('2a02:20::')
    expect(IPv6Net.new('2a02:20::/128').prefix_hex).to eq('2a02:20::')
  end
end

describe IPv6Net, :unicast? do
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

describe IPv6Net, :multicast? do
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

describe IPv6Net, :new_pb_multicast do
  it 'produces correct address' do
    expect(IPv6Net.new('2a02:20:1:2::5/64').new_pb_multicast(:global, 0x1234)).to eq('ff3e:40:2a02:20:1:2:0:1234')
  end
end

describe IPv6Net, :reverse do
  it 'calculates the correct values' do
    expect(IPv6Net.new('::/0').reverse).to eq('.ip6.arpa')
    expect(IPv6Net.new('2a02:20:1:2::/64').reverse).to eq('2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa')
    expect(IPv6Net.new('2a02:20:1:2::5/128').reverse).to eq(
      '5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa')
  end
end


# parent class methods

describe IPv6Net, :prefix= do
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

describe IPv6Net, :length= do
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

describe IPv6Net, :mask do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').mask).to eq(0x00000000000000000000000000000000)
    expect(IPv6Net.new('2a00::/8').mask).to eq(0xff000000000000000000000000000000)
    expect(IPv6Net.new('2a02:20::/32').mask).to eq(0xffffffff000000000000000000000000)
    expect(IPv6Net.new('2a02:20::/127').mask).to eq(0xfffffffffffffffffffffffffffffffe)
    expect(IPv6Net.new('2a02:20::/128').mask).to eq(0xffffffffffffffffffffffffffffffff)
  end
end

describe IPv6Net, :wildcard do
  it 'is correctly calculated' do
    expect(IPv6Net.new('::/0').wildcard).to eq(0xffffffffffffffffffffffffffffffff)
    expect(IPv6Net.new('2a00::/8').wildcard).to eq(0x00ffffffffffffffffffffffffffffff)
    expect(IPv6Net.new('2a02:20::/32').wildcard).to eq(0x00000000ffffffffffffffffffffffff)
    expect(IPv6Net.new('2a02:20::/127').wildcard).to eq(0x00000000000000000000000000000001)
    expect(IPv6Net.new('2a02:20::/128').wildcard).to eq(0x00000000000000000000000000000000)
  end
end

describe IPv6Net, :addresses do
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

describe IPv6Net, :first_ip do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').first_ip).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::0/127').first_ip).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::1/128').first_ip).to eq(0x2a020020000100020000000000000001)
  end
end

describe IPv6Net, :last_ip do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').last_ip).to eq(0x2a02002000010002ffffffffffffffff)
    expect(IPv6Net.new('2a02:20:1:2::0/127').last_ip).to eq(0x2a020020000100020000000000000001)
    expect(IPv6Net.new('2a02:20:1:2::1/128').last_ip).to eq(0x2a020020000100020000000000000001)
  end
end

describe IPv6Net, :hosts do
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

describe IPv6Net, :first_host do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').first_host).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::0/127').first_host).to eq(0x2a020020000100020000000000000000)
    expect(IPv6Net.new('2a02:20:1:2::1/128').first_host).to eq(0x2a020020000100020000000000000001)
  end
end

describe IPv6Net, :last_host do
  it 'calculates the correct values' do
    expect(IPv6Net.new('2a02:20:1:2::/64').last_host).to eq(0x2a02002000010002ffffffffffffffff)
    expect(IPv6Net.new('2a02:20:1:2::0/127').last_host).to eq(0x2a020020000100020000000000000001)
    expect(IPv6Net.new('2a02:20:1:2::1/128').last_host).to eq(0x2a020020000100020000000000000001)
  end
end

describe IPv6Net, :include? do
  it 'matches correctly' do
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:19::0'))).to be_falsey
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20::0'))).to be_truthy
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20::1'))).to be_truthy
    expect((IPv6Net.new('2a02:20::1/32').include?('2a02:20:ffff::1'))).to be_truthy
  end
end

describe IPv6Net, :to_s do
  it 'produces correct output' do
    expect(IPv6Net.new('::/0').to_s).to eq('::/0')
    expect(IPv6Net.new('2a00::/8').to_s).to eq('2a00::/8')
    expect(IPv6Net.new('2aff::0/8').to_s).to eq('2a00::/8')
    expect(IPv6Net.new('2a02:20::/32').to_s).to eq('2a02:20::/32')
    expect(IPv6Net.new('2a02:20::/127').to_s).to eq('2a02:20::/127')
    expect(IPv6Net.new('2a02:20::/128').to_s).to eq('2a02:20::/128')
  end
end

describe IPv6Net, 'to_hash' do
  it 'produces correct output' do
    expect(IPv6Net.new('2a02:20::/128').to_hash).to eq({ :prefix => '2a02:20::', :length => 128 })
  end
end

describe IPv6Net, :== do
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

describe IPv6Net, :< do
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

describe IPv6Net, :<= do
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

describe IPv6Net, :> do
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

describe IPv6Net, :>= do
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

describe IPv6Net, :overlaps? do
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

describe IPv6Net, :>> do
  it 'operates correctly' do
    expect(IPv6Net.new('2a02:20::/32') >> 1).to eq('2a02:20::/33')
  end
end

describe IPv6Net, :<< do
  it 'operates correctly' do
    expect(IPv6Net.new('2a02:20::/32') << 1).to eq('2a02:20::/31')
    expect(IPv6Net.new('2a02:21::/32') << 1).to eq('2a02:20::/31')
  end
end

describe IPv6Net, :=== do
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

describe IPv6Net, :<=> do
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

end
