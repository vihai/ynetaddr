#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv6IfAddr do

describe 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    expect(IPv6IfAddr.new('2a02:20:1:2:3:4:5:6/64').addr).to eq(0x2a020020000100020003000400050006)
    expect(IPv6IfAddr.new('2a02:20:1:2:3:4:5:6/64').length).to eq(64)
  end

# IPAddr is buggy!!!!!!!!!
#  require 'ipaddr'
#  it 'accepts ::IPAddr' do
#    expect(IPv6IfAddr.new(::IPAddr.new('2a02:20:1:2:3:4:5:6/64')).addr.to_i).to eq(0x2a020020000100020003000400050006)
#    expect(IPv6IfAddr.new(::IPAddr.new('2a02:20:1:2:3:4:5:6/64')).length).to eq(64)
#  end

  it 'rejects network address' do
    expect { IPv6IfAddr.new('2a02:20::/64') }.to raise_error(ArgumentError)
  end

  it 'reject invalid empty address' do
    expect { IPv6IfAddr.new('') }.to raise_error(ArgumentError)
  end

  it 'reject addr without length' do
    expect { IPv6IfAddr.new('2a02:20::1') }.to raise_error(ArgumentError)
  end

  it 'reject addr with slash but without length' do
    expect { IPv6IfAddr.new('2a02:20::1/') }.to raise_error(ArgumentError)
  end

  it 'reject addr without addr' do
    expect { IPv6IfAddr.new('/64') }.to raise_error(ArgumentError)
  end

  it 'accepts a Hash with addr and mask keys with integer addr and length' do
    expect(IPv6IfAddr.new(addr_binary: 'AEIO1234567890XY', length: 128).addr).to eq(0x4145494f313233343536373839305859)
    expect(IPv6IfAddr.new(addr_binary: 'AEIO1234567890XY', length: 128).length).to eq(128)
  end

  it 'raises ArgumentError if length > 32' do
    expect { IPv6IfAddr.new(addr: '2a02:20::', length: 129) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError if length < 0' do
    expect { IPv6IfAddr.new(addr: '2a02:20::', length: -1) }.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { IPv6IfAddr.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end
end

describe :mask_hex do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').mask_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6IfAddr.new('2a::1/8').mask_hex).to eq('ff00:0000:0000:0000:0000:0000:0000:0000')
    expect(IPv6IfAddr.new('2a02:20::1/32').mask_hex).to eq('ffff:ffff:0000:0000:0000:0000:0000:0000')
    expect(IPv6IfAddr.new('2a02:20::1/127').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe')
    expect(IPv6IfAddr.new('2a02:20::1/128').mask_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
  end
end

describe :wildcard_hex do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').wildcard_hex).to eq('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6IfAddr.new('2a::1/8').wildcard_hex).to eq('00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6IfAddr.new('2a02:20::1/32').wildcard_hex).to eq('0000:0000:ffff:ffff:ffff:ffff:ffff:ffff')
    expect(IPv6IfAddr.new('2a02:20::1/127').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0001')
    expect(IPv6IfAddr.new('2a02:20::1/128').wildcard_hex).to eq('0000:0000:0000:0000:0000:0000:0000:0000')
  end
end

# parent class methods

describe :network do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').network).to eq('::/0')
    expect(IPv6IfAddr.new('2a::1/8').network).to eq('2a::/8')
    expect(IPv6IfAddr.new('2a02:20::1/32').network).to eq('2a02:20::/32')
    expect(IPv6IfAddr.new('2a02:20:ffff:ffff:ffff:ffff:ffff:ffff/32').network).to eq('2a02:20::/32')
    expect(IPv6IfAddr.new('2a02:20::1/127').network).to eq('2a02:20::0/127')
    expect(IPv6IfAddr.new('2a02:20::1/128').network).to eq('2a02:20::1/128')
  end
end

describe :mask do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').mask).to eq(0x00000000000000000000000000000000)
    expect(IPv6IfAddr.new('2a::1/8').mask).to eq(0xff000000000000000000000000000000)
    expect(IPv6IfAddr.new('2a02:20::1/32').mask).to eq(0xffffffff000000000000000000000000)
    expect(IPv6IfAddr.new('2a02:20::1/127').mask).to eq(0xfffffffffffffffffffffffffffffffe)
    expect(IPv6IfAddr.new('2a02:20::1/128').mask).to eq(0xffffffffffffffffffffffffffffffff)
  end
end

describe :wildcard do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').wildcard).to eq(0xffffffffffffffffffffffffffffffff)
    expect(IPv6IfAddr.new('2a::1/8').wildcard).to eq(0x00ffffffffffffffffffffffffffffff)
    expect(IPv6IfAddr.new('2a02:20::1/32').wildcard).to eq(0x00000000ffffffffffffffffffffffff)
    expect(IPv6IfAddr.new('2a02:20::1/127').wildcard).to eq(0x00000000000000000000000000000001)
    expect(IPv6IfAddr.new('2a02:20::1/128').wildcard).to eq(0x00000000000000000000000000000000)
  end
end


describe :address do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').address).to eq('::1')
    expect(IPv6IfAddr.new('2a::1/8').address).to eq('2a::1')
    expect(IPv6IfAddr.new('2a02:20::1/32').address).to eq('2a02:20::1')
    expect(IPv6IfAddr.new('2a02:20::1/127').address).to eq('2a02:20::1')
    expect(IPv6IfAddr.new('2a02:20::1/128').address).to eq('2a02:20::1')
  end
end

describe :nic_id do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::1/0').nic_id).to eq(1)
    expect(IPv6IfAddr.new('2a::1/8').nic_id).to eq(0x002a0000000000000000000000000001)
    expect(IPv6IfAddr.new('2a02:20::1/32').nic_id).to eq(1)
    expect(IPv6IfAddr.new('2a02:20::1/127').nic_id).to eq(1)
    expect(IPv6IfAddr.new('2a02:20::1/128').nic_id).to eq(0)
  end
end

describe :include? do
  it 'matches correctly' do
    expect(IPv6IfAddr.new('2a02:20::1/32').include?('2a02:19::0')).to be_falsey
    expect(IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20::0')).to be_truthy
    expect(IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20::1')).to be_truthy
    expect(IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20:ffff::1')).to be_truthy
  end
end

describe :== do
  it 'return true if interface addresses are equal' do
    expect(IPv6IfAddr.new('2a02:20::1/32') == '2a02:20::1/32').to be_truthy
  end

  it 'returns false if interface addreses have different address' do
    expect(IPv6IfAddr.new('2a02:20::2/32') == '2a02:20::1/32').to be_falsey
  end

  it 'returns false if interface addreses have different mask length' do
    expect(IPv6IfAddr.new('2a02:20::1/32') == '2a02:20::1/31').to be_falsey
  end

  it 'returns false if comparing with IPv4IfAddr' do
    expect(IPv6IfAddr.new('2a02:20::1/32') == IPv4IfAddr.new('192.168.0.1/24')).to be_falsey
  end

  it 'returns false if comparing with IPv4 string' do
    expect(IPv6IfAddr.new('2a02:20::1/32') == '192.168.0.1/24').to be_falsey
  end
end

describe :to_s do
  it 'produces correct output' do
    expect(IPv6IfAddr.new('::1/0').to_s).to eq('::1/0')
    expect(IPv6IfAddr.new('2a::1/8').to_s).to eq('2a::1/8')
    expect(IPv6IfAddr.new('2a02:20::1/32').to_s).to eq('2a02:20::1/32')
    expect(IPv6IfAddr.new('2a02:20::1/127').to_s).to eq('2a02:20::1/127')
    expect(IPv6IfAddr.new('2a02:20::1/128').to_s).to eq('2a02:20::1/128')
  end
end

describe :to_hash do
  it 'is correctly calculated' do
    expect(IPv6IfAddr.new('::5/32')).to eq({ :addr => 0x5, :length => 32 })
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(IPv6IfAddr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64').to_json).to eq('"2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(IPv6IfAddr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64').to_yaml).to eq("--- 2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64\n")
  end
end

describe :ipv4? do
  it 'returns false' do
    expect(IPv6IfAddr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64').ipv4?).to be_falsey
  end
end

describe :ipv6? do
  it 'returns true' do
    expect(IPv6IfAddr.new('2a02:1234:abcd:0:9999:ffff:a90b:bbbb/64').ipv6?).to be_truthy
  end
end

end

end
