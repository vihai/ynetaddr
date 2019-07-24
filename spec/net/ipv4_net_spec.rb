#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv4Net do

describe 'constructor' do
  it 'accepts d.d.d.d/l format' do
    expect(IPv4Net.new('192.168.0.0/24').prefix).to eq(0xC0A80000)
    expect(IPv4Net.new('192.168.0.0/24').length).to eq(24)
  end

  it 'resets host bits' do
    expect(IPv4Net.new('10.0.255.0/16').prefix).to eq(0x0A000000)
  end

  it 'reject invalid empty address' do
    expect { IPv4Net.new('') }.to raise_error(ArgumentError)
  end

  it 'reject prefix without length' do
    expect { IPv4Net.new('10.0.255.0') }.to raise_error(ArgumentError)
  end

  it 'reject prefix with slash but without length' do
    expect { IPv4Net.new('10.0.255.0/') }.to raise_error(ArgumentError)
  end

  it 'reject prefix without prefix' do
    expect { IPv4Net.new('/24') }.to raise_error(ArgumentError)
  end

  it 'accepts a Hash with addr and mask keys with string addr and mask' do
    expect(IPv4Net.new(prefix: '192.168.0.1', mask: '255.255.255.0').prefix).to eq(0xC0A80000)
    expect(IPv4Net.new(prefix: '192.168.0.1', mask: '255.255.255.0').length).to eq(24)
  end

  it 'accepts a Hash with addr and mask keys with prefix_binary and mask' do
    expect(IPv4Net.new(prefix: 0xC0A80001, mask: 0xffffff00).prefix).to eq(0xC0A80000)
    expect(IPv4Net.new(prefix: 0xC0A80001, mask: 0xffffff00).length).to eq(24)
  end

  it 'accepts a Hash with addr and mask keys with integer addr and mask' do
    expect(IPv4Net.new(prefix_binary: 'AEIO', mask: 0xffffffff).prefix).to eq(0x4145494f)
    expect(IPv4Net.new(prefix_binary: 'AEIO', mask: 0xffffffff).length).to eq(32)
  end
end

describe :mask_dotquad do
  it 'is correctly calculated' do
    expect(IPv4Net.new('0.0.0.0/0').mask_dotquad).to eq('0.0.0.0')
    expect(IPv4Net.new('10.255.255.0/8').mask_dotquad).to eq('255.0.0.0')
    expect(IPv4Net.new('10.255.255.0/31').mask_dotquad).to eq('255.255.255.254')
    expect(IPv4Net.new('10.255.255.0/32').mask_dotquad).to eq('255.255.255.255')
  end
end

describe :wildcard_dotquad do
  it 'is correctly calculated' do
    expect(IPv4Net.new('0.0.0.0/0').wildcard_dotquad).to eq('255.255.255.255')
    expect(IPv4Net.new('10.255.255.0/8').wildcard_dotquad).to eq('0.255.255.255')
    expect(IPv4Net.new('10.255.255.0/31').wildcard_dotquad).to eq('0.0.0.1')
    expect(IPv4Net.new('10.255.255.0/32').wildcard_dotquad).to eq('0.0.0.0')
  end
end

describe :prefix_dotquad do
  it 'calculates the correct value' do
    expect(IPv4Net.new('192.168.0.0/29').prefix_dotquad).to eq('192.168.0.0')
    expect(IPv4Net.new('192.168.0.0/30').prefix_dotquad).to eq('192.168.0.0')
    expect(IPv4Net.new('192.168.0.0/31').prefix_dotquad).to eq('192.168.0.0')
    expect(IPv4Net.new('192.168.0.0/32').prefix_dotquad).to eq('192.168.0.0')
  end
end

describe :ipclass do
  it 'is correctly calculated' do
    expect(IPv4Net.new('10.0.0.0/8').ipclass).to eq(:a)
    expect(IPv4Net.new('172.16.0.0/12').ipclass).to eq(:b)
    expect(IPv4Net.new('192.168.0.0/16').ipclass).to eq(:c)
    expect(IPv4Net.new('224.0.0.0/32').ipclass).to eq(:d)
    expect(IPv4Net.new('240.0.0.0/32').ipclass).to eq(:e)
  end

  it 'should raise an error for network spanning more than one class' do
    expect { IPv4Net.new('0.0.0.0/0').ipclass }.to raise_error(ClassUndetermined)
  end
end

describe :unicast? do
  it 'is correctly calculated' do
    expect(IPv4Net.new('10.0.0.0/8').unicast?).to be_truthy
    expect(IPv4Net.new('172.16.0.0/12').unicast?).to be_truthy
    expect(IPv4Net.new('192.168.0.0/16').unicast?).to be_truthy
    expect(IPv4Net.new('224.0.0.0/32').unicast?).to be_falsey
    expect(IPv4Net.new('240.0.0.0/32').unicast?).to be_falsey
  end
end

describe :multicast? do
  it 'is correctly calculated' do
    expect(IPv4Net.new('10.0.0.0/8').multicast?).to be_falsey
    expect(IPv4Net.new('172.16.0.0/12').multicast?).to be_falsey
    expect(IPv4Net.new('192.168.0.0/16').multicast?).to be_falsey
    expect(IPv4Net.new('224.0.0.0/32').multicast?).to be_truthy
    expect(IPv4Net.new('240.0.0.0/32').multicast?).to be_falsey
  end
end

describe :broadcast do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').broadcast).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct value' do
    expect(IPv4Net.new('192.168.0.0/29').broadcast).to eq(0xc0a80007)
    expect(IPv4Net.new('192.168.0.0/30').broadcast).to eq(0xc0a80003)
    expect(IPv4Net.new('192.168.0.0/31').broadcast).to be_nil
    expect(IPv4Net.new('192.168.0.0/32').broadcast).to be_nil
  end
end

describe :reverse do
  it 'calculates the correct values' do
    expect(IPv4Net.new('0.0.0.0/0').reverse).to eq('.in-addr.arpa')
    expect(IPv4Net.new('10.0.0.0/8').reverse).to eq('10.in-addr.arpa')
    expect(IPv4Net.new('172.16.0.0/12').reverse).to eq('172.in-addr.arpa')
    expect(IPv4Net.new('192.168.0.0/16').reverse).to eq('168.192.in-addr.arpa')
    expect(IPv4Net.new('192.168.32.0/24').reverse).to eq('32.168.192.in-addr.arpa')
    expect(IPv4Net.new('192.168.32.1/32').reverse).to eq('1.32.168.192.in-addr.arpa')
  end
end

describe 'is_rfc1918?' do
  it 'calculates the correct values' do
    expect(IPv4Net.new('0.0.0.0/0').is_rfc1918?).to be_falsey
    expect(IPv4Net.new('1.0.0.0/8').is_rfc1918?).to be_falsey
    expect(IPv4Net.new('10.0.0.0/8').is_rfc1918?).to be_truthy
    expect(IPv4Net.new('172.15.0.0/12').is_rfc1918?).to be_falsey
    expect(IPv4Net.new('172.16.0.0/12').is_rfc1918?).to be_truthy
    expect(IPv4Net.new('192.167.0.0/16').is_rfc1918?).to be_falsey
    expect(IPv4Net.new('192.168.0.0/16').is_rfc1918?).to be_truthy
    expect(IPv4Net.new('192.168.32.0/24').is_rfc1918?).to be_truthy
    expect(IPv4Net.new('192.168.32.1/32').is_rfc1918?).to be_truthy
    expect(IPv4Net.new('192.169.32.1/32').is_rfc1918?).to be_falsey
  end
end

# parent class methods

describe :prefix= do
  it 'returns prefix' do
    expect((IPv4Net.new('192.168.0.0/16').prefix = '192.167.0.0')).to eq('192.167.0.0')
  end

  it 'assigns prefix host bits' do
    a = IPv4Net.new('192.168.0.0/16')
    a.prefix = '192.167.0.0'
    expect(a).to eq(IPv4Net.new('192.167.0.0/16'))
  end

  it 'resets host bits' do
    a = IPv4Net.new('192.168.0.0/16')
    a.prefix = '192.167.0.255'
    expect(a).to eq(IPv4Net.new('192.167.0.0/16'))
  end
end

describe :length= do
  it 'returns length' do
    expect((IPv4Net.new('192.168.0.0/24').length = 16)).to eq(16)
  end

  it 'rejects invalid length' do
    expect { IPv4Net.new('192.168.0.0/24').length = -1 }.to raise_error(ArgumentError)
    expect { IPv4Net.new('192.168.0.0/24').length = 33 }.to raise_error(ArgumentError)
  end

  it 'resets host bits' do
    a = IPv4Net.new('192.168.22.0/24')
    a.length = 16
    expect(a).to eq(IPv4Net.new('192.168.0.0/16'))
  end
end

describe :mask do
  it 'is kind of Integer' do
    expect(IPv4Net.new('0.0.0.0/0').mask).to be_an_kind_of(Integer)
  end

  it 'is correctly calculated' do
    expect(IPv4Net.new('0.0.0.0/0').mask).to eq(0x00000000)
    expect(IPv4Net.new('10.255.255.0/8').mask).to eq(0xff000000)
    expect(IPv4Net.new('10.255.255.0/31').mask).to eq(0xfffffffe)
    expect(IPv4Net.new('10.255.255.0/32').mask).to eq(0xffffffff)
  end
end

describe :wildcard do
  it 'is kind of Integer' do
    expect(IPv4Net.new('0.0.0.0/0').wildcard).to be_an_kind_of(Integer)
  end

  it 'is correctly calculated' do
    expect(IPv4Net.new('0.0.0.0/0').wildcard).to eq(0xffffffff)
    expect(IPv4Net.new('10.255.255.0/8').wildcard).to eq(0x00ffffff)
    expect(IPv4Net.new('10.255.255.0/31').wildcard).to eq(0x00000001)
    expect(IPv4Net.new('10.255.255.0/32').wildcard).to eq(0x00000000)
  end
end

describe :addresses do
  it 'produces a range' do
    expect(IPv4Net.new('10.0.0.0/8').addresses).to be_kind_of(Range)
  end

  it 'produces the correct range' do
    expect(IPv4Net.new('192.168.0.0/29').addresses).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.7'))
    expect(IPv4Net.new('192.168.0.0/30').addresses).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.3'))
    expect(IPv4Net.new('192.168.0.0/31').addresses).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.1'))
    expect(IPv4Net.new('192.168.0.0/32').addresses).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.0'))
  end
end

describe :first_ip do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').first_ip).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    expect(IPv4Net.new('192.168.0.0/29').first_ip).to eq(0xc0a80000)
    expect(IPv4Net.new('192.168.0.0/30').first_ip).to eq(0xc0a80000)
    expect(IPv4Net.new('192.168.0.0/31').first_ip).to eq(0xc0a80000)
    expect(IPv4Net.new('192.168.0.0/32').first_ip).to eq(0xc0a80000)
  end
end

describe :last_ip do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').first_ip).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    expect(IPv4Net.new('192.168.0.0/29').last_ip).to eq(0xc0a80007)
    expect(IPv4Net.new('192.168.0.0/30').last_ip).to eq(0xc0a80003)
    expect(IPv4Net.new('192.168.0.0/31').last_ip).to eq(0xc0a80001)
    expect(IPv4Net.new('192.168.0.0/32').last_ip).to eq(0xc0a80000)
  end
end

describe :hosts do
  it 'produces a range' do
    expect(IPv4Net.new('10.0.0.0/8').hosts).to be_kind_of(Range)
  end

  it 'produces the correct range' do
    expect(IPv4Net.new('192.168.0.0/29').hosts).to eq(
      IPv4Addr.new('192.168.0.1')..IPv4Addr.new('192.168.0.6'))
    expect(IPv4Net.new('192.168.0.0/30').hosts).to eq(
      IPv4Addr.new('192.168.0.1')..IPv4Addr.new('192.168.0.2'))
    expect(IPv4Net.new('192.168.0.0/31').hosts).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.1'))
    expect(IPv4Net.new('192.168.0.0/32').hosts).to eq(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.0'))
  end
end

describe :first_host do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').first_host).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    expect(IPv4Net.new('192.168.0.0/29').first_host).to eq(0xc0a80001)
    expect(IPv4Net.new('192.168.0.0/30').first_host).to eq(0xc0a80001)
    expect(IPv4Net.new('192.168.0.0/31').first_host).to eq(0xc0a80000)
    expect(IPv4Net.new('192.168.0.0/32').first_host).to eq(0xc0a80000)
  end
end

describe :last_host do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').first_host).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    expect(IPv4Net.new('192.168.0.0/29').last_host).to eq(0xc0a80006)
    expect(IPv4Net.new('192.168.0.0/30').last_host).to eq(0xc0a80002)
    expect(IPv4Net.new('192.168.0.0/31').last_host).to eq(0xc0a80001)
    expect(IPv4Net.new('192.168.0.0/32').last_host).to eq(0xc0a80000)
  end
end

describe :network do
  it 'is of type IPv4Addr' do
    expect(IPv4Net.new('0.0.0.0/0').network).to be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    expect(IPv4Net.new('192.168.0.255/24').network).to eq(IPv4Addr.new('192.168.0.0'))
    expect(IPv4Net.new('192.168.0.0/29').network).to eq(IPv4Addr.new('192.168.0.0'))
    expect(IPv4Net.new('192.168.0.0/30').network).to eq(IPv4Addr.new('192.168.0.0'))
    expect(IPv4Net.new('192.168.0.0/31').network).to eq(nil)
    expect(IPv4Net.new('192.168.0.0/32').network).to eq(nil)
  end
end

describe :include? do
  it 'calculates the correct values' do
    expect(IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('1.2.3.4'))).to be_truthy
    expect(IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('0.0.0.0'))).to be_truthy
    expect(IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('255.255.255.255'))).to be_truthy
    expect(IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('9.255.255.255'))).to be_falsey
    expect(IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('10.0.0.0'))).to be_truthy
    expect(IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('10.255.255.255'))).to be_truthy
    expect(IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('11.0.0.0'))).to be_falsey
  end
end

describe :to_s do
  it 'produces correct output' do
    expect(IPv4Net.new('0.0.0.0/0').to_s).to eq('0.0.0.0/0')
    expect(IPv4Net.new('10.0.0.0/8').to_s).to eq('10.0.0.0/8')
    expect(IPv4Net.new('192.168.255.255/24').to_s).to eq('192.168.255.0/24')
    expect(IPv4Net.new('192.168.255.255/32').to_s).to eq('192.168.255.255/32')
  end
end

describe :to_hash do
  it 'produces correct output' do
    expect(IPv4Net.new('0.0.0.0/0').to_hash).to eq({ :prefix => 0x00000000, :length => 0 })
    expect(IPv4Net.new('10.0.0.0/8').to_hash).to eq({ :prefix => 0x0a000000, :length => 8 })
    expect(IPv4Net.new('192.168.255.255/24').to_hash).to eq({ :prefix => 0xc0a8ff00, :length => 24 })
    expect(IPv4Net.new('192.168.255.255/32').to_hash).to eq({ :prefix => 0xc0a8ffff, :length => 32 })
  end
end

describe :== do
  it 'matches equal networks' do
    expect((IPv4Net.new('0.0.0.0/0') == IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/0') == IPv4Net.new('4.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('10.0.0.0/8') == IPv4Net.new('10.0.0.0/8'))).to be_truthy
    expect((IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.0/24'))).to be_truthy
    expect((IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.255/24'))).to be_truthy
    expect((IPv4Net.new('192.168.255.255/32') == IPv4Net.new('192.168.255.255/32'))).to be_truthy
  end

  it 'doesn\'t match different networks' do
    expect((IPv4Net.new('10.0.0.0/8') == IPv4Net.new('13.0.0.0/8'))).to be_falsey
    expect((IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.255/32'))).to be_falsey
    expect((IPv4Net.new('192.168.255.255/32') == IPv4Net.new('192.168.255.255/24'))).to be_falsey
  end
end

describe :< do
  it 'compares correctly' do
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.1.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('5.5.5.5/0'))).to be_truthy
    expect((IPv4Net.new('5.5.5.5/0') < IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/0') < IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/16'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/23'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/25'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/32'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') < IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') < IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/1') < IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/0') < IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('255.255.255.255/32') < IPv4Net.new('0.0.0.0/0'))).to be_truthy
  end

  it 'compares correctly with Range' do
    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.3.0')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.128')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') < (IPv4Addr.new('192.168.1.128')..IPv4Addr.new('192.168.2.255')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/32') < (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.0')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/32') < (IPv4Addr.new('192.168.0.255')..IPv4Addr.new('192.168.1.1')))).to be_truthy
  end
end

describe :<= do
  it 'compares correctly' do
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.1.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('5.5.5.5/0'))).to be_truthy
    expect((IPv4Net.new('5.5.5.5/0') <= IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/0') <= IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/16'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/23'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/24'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/25'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/32'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') <= IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/1') <= IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('0.0.0.0/0') <= IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('255.255.255.255/32') <= IPv4Net.new('0.0.0.0/0'))).to be_truthy
  end

  it 'compares correctly with Range' do
    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.1.255')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_truthy

    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.3.0')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.128')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') <= (IPv4Addr.new('192.168.1.128')..IPv4Addr.new('192.168.2.255')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/32') <= (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.0')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/32') <= (IPv4Addr.new('192.168.0.255')..IPv4Addr.new('192.168.1.1')))).to be_truthy
  end
end

describe :> do
  it 'compares correctly' do
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.1.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('5.5.5.5/0'))).to be_falsey
    expect((IPv4Net.new('5.5.5.5/0') > IPv4Net.new('192.168.0.0/24'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/16'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/23'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/25'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/32'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') > IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') > IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') > IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/0') > IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('255.255.255.255/32') > IPv4Net.new('0.0.0.0/0'))).to be_falsey
  end

  it 'compares correctly with Range' do
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.1')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.128')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.1')..IPv4Addr.new('192.168.1.254')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.128')..IPv4Addr.new('192.168.1.255')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/32') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.0')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/32') > (IPv4Addr.new('192.168.0.255')..IPv4Addr.new('192.168.1.1')))).to be_falsey
  end
end

describe :>= do
  it 'compares correctly' do
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.1.0/24'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('5.5.5.5/0'))).to be_falsey
    expect((IPv4Net.new('5.5.5.5/0') >= IPv4Net.new('192.168.0.0/24'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/16'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/23'))).to be_falsey
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/24'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/25'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/32'))).to be_truthy
    expect((IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') >= IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/1') >= IPv4Net.new('0.0.0.0/0'))).to be_falsey
    expect((IPv4Net.new('0.0.0.0/0') >= IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect((IPv4Net.new('255.255.255.255/32') >= IPv4Net.new('0.0.0.0/0'))).to be_falsey
  end

  it 'compares correctly with Range' do
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.1')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.128')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.1')..IPv4Addr.new('192.168.1.254')))).to be_truthy
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.255')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/24') > (IPv4Addr.new('192.168.1.128')..IPv4Addr.new('192.168.1.255')))).to be_falsey

    expect((IPv4Net.new('192.168.1.0/32') > (IPv4Addr.new('192.168.1.0')..IPv4Addr.new('192.168.1.0')))).to be_falsey
    expect((IPv4Net.new('192.168.1.0/32') > (IPv4Addr.new('192.168.0.255')..IPv4Addr.new('192.168.1.1')))).to be_falsey
  end
end

describe :overlaps? do
  it 'is false for smaller non-overlapping networks' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('10.1.1.1/24'))).to be_falsey
  end

  it 'is false for bigger non-overlapping networks' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('10.0.0.0/8'))).to be_falsey
  end

  it 'is false for equal-size non-overlapping networks' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('192.169.0.0/16'))).to be_falsey
  end

  it 'is true for same network' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('192.168.0.0/16'))).to be_truthy
  end

  it 'is true for bigger network containing us' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('192.0.0.0/8'))).to be_truthy
  end

  it 'is true for smaller network contained' do
    expect((IPv4Net.new('192.168.0.0/16').overlaps?('192.168.16.0/24'))).to be_truthy
  end
end

describe :>> do
  it 'operates correctly' do
    expect((IPv4Net.new('192.168.0.0/24') >> 1)).to eq(IPv4Net.new('192.168.0.0/25'))
    expect((IPv4Net.new('192.168.0.0/24') >> 2)).to eq(IPv4Net.new('192.168.0.0/26'))
    expect((IPv4Net.new('192.168.0.0/24') >> 9)).to eq(IPv4Net.new('192.168.0.0/32'))
    expect((IPv4Net.new('192.168.0.0/24') >> -1)).to eq(IPv4Net.new('192.168.0.0/23'))
  end
end

describe :<< do
  it 'operates correctly' do
    expect((IPv4Net.new('192.168.0.0/24') << 1)).to eq(IPv4Net.new('192.168.0.0/23'))
    expect((IPv4Net.new('192.168.0.0/24') << 2)).to eq(IPv4Net.new('192.168.0.0/22'))
    expect((IPv4Net.new('192.168.0.0/24') << 25)).to eq(IPv4Net.new('0.0.0.0/0'))
    expect((IPv4Net.new('192.168.0.0/24') << -1)).to eq(IPv4Net.new('192.168.0.0/25'))
  end
end

describe :=== do
  it 'returns true if other is an IPv4 address and is contained in this network' do
    expect((IPv4Net.new('192.168.0.0/24') === IPv4Addr.new('192.168.0.254'))).to be_truthy
  end

  it 'returns false if other is not contained in this network' do
    expect((IPv4Net.new('192.168.0.0/24') === IPv4Addr.new('192.168.1.254'))).to be_falsey
  end

  it 'returns false if other is not IPv4 address' do
    expect((IPv4Net.new('192.168.0.0/24') === 1234)).to be_falsey
  end
end

describe :<=> do
  it 'returns 0 if networks are equal' do
    expect((IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/24'))).to eq(0)
  end

  it 'returns -1 if networks have the same prefix length and prefix a < prefix b' do
    expect((IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.169.0.0/24'))).to eq(-1)
  end

  it 'returns +1 if networks have the same prefix length and prefix a < prefix b' do
    expect((IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.167.0.0/24'))).to eq(1)
  end

  it 'returns -1 if network a is smaller than network b' do
    expect((IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/23'))).to eq(-1)
  end

  it 'returns +1 if network a is bigger than network b' do
    expect((IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/25'))).to eq(1)
  end
end

describe :+ do
  it 'returns of type IPv4Addr' do
    expect((IPv4Net.new('1.2.3.0/24') + 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'sums correctly' do
    expect((IPv4Net.new('1.2.3.0/24') + 1)).to eq(IPv4Addr.new('1.2.3.1'))
    expect((IPv4Net.new('1.2.3.0/24') + (-1))).to eq(IPv4Addr.new('1.2.2.255'))
    expect((IPv4Net.new('1.2.3.0/24') + 10)).to eq(IPv4Addr.new('1.2.3.10'))
  end
end

describe :- do
  it 'returns of type IPv4Addr' do
    expect((IPv4Net.new('1.2.3.0/24') - 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'subtracts correctly' do
    expect((IPv4Net.new('1.2.3.0/24') - 1)).to eq(IPv4Addr.new('1.2.2.255'))
    expect((IPv4Net.new('1.2.3.0/24') - (-1))).to eq(IPv4Addr.new('1.2.3.1'))
    expect((IPv4Net.new('1.2.3.0/24') - 10)).to eq(IPv4Addr.new('1.2.2.246'))
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(IPv4Net.new('1.2.3.0/24').to_json).to eq('"1.2.3.0/24"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(IPv4Net.new('1.2.3.0/24').to_yaml).to eq("--- 1.2.3.0/24\n")
  end
end

describe :mask_to_length do
  it 'converts mask to a length' do
    expect(IPv4Net.mask_to_length(0xffffffff)).to eq(32)
    expect(IPv4Net.mask_to_length(0xfffffffe)).to eq(31)
    expect(IPv4Net.mask_to_length(0xfffffffc)).to eq(30)
    expect(IPv4Net.mask_to_length(0xfffffff8)).to eq(29)
    expect(IPv4Net.mask_to_length(0xfffffff0)).to eq(28)
    expect(IPv4Net.mask_to_length(0xffffffe0)).to eq(27)
    expect(IPv4Net.mask_to_length(0xffffffc0)).to eq(26)
    expect(IPv4Net.mask_to_length(0xffffff80)).to eq(25)
    expect(IPv4Net.mask_to_length(0xffffff00)).to eq(24)
    expect(IPv4Net.mask_to_length(0xfffffe00)).to eq(23)
    expect(IPv4Net.mask_to_length(0xfffffc00)).to eq(22)
    expect(IPv4Net.mask_to_length(0xfffff800)).to eq(21)
    expect(IPv4Net.mask_to_length(0xfffff000)).to eq(20)
    expect(IPv4Net.mask_to_length(0xffffe000)).to eq(19)
    expect(IPv4Net.mask_to_length(0xffffc000)).to eq(18)
    expect(IPv4Net.mask_to_length(0xffff8000)).to eq(17)
    expect(IPv4Net.mask_to_length(0xffff0000)).to eq(16)
    expect(IPv4Net.mask_to_length(0xfffe0000)).to eq(15)
    expect(IPv4Net.mask_to_length(0xfffc0000)).to eq(14)
    expect(IPv4Net.mask_to_length(0xfff80000)).to eq(13)
    expect(IPv4Net.mask_to_length(0xfff00000)).to eq(12)
    expect(IPv4Net.mask_to_length(0xffe00000)).to eq(11)
    expect(IPv4Net.mask_to_length(0xffc00000)).to eq(10)
    expect(IPv4Net.mask_to_length(0xff800000)).to eq(9)
    expect(IPv4Net.mask_to_length(0xff000000)).to eq(8)
    expect(IPv4Net.mask_to_length(0xfe000000)).to eq(7)
    expect(IPv4Net.mask_to_length(0xfc000000)).to eq(6)
    expect(IPv4Net.mask_to_length(0xf8000000)).to eq(5)
    expect(IPv4Net.mask_to_length(0xf0000000)).to eq(4)
    expect(IPv4Net.mask_to_length(0xe0000000)).to eq(3)
    expect(IPv4Net.mask_to_length(0xc0000000)).to eq(2)
    expect(IPv4Net.mask_to_length(0x80000000)).to eq(1)
    expect(IPv4Net.mask_to_length(0x00000000)).to eq(0)
  end
end

describe :length_to_mask do
  it 'converts mask to a length' do
    expect(IPv4Net.length_to_mask(32)).to eq(0xffffffff)
    expect(IPv4Net.length_to_mask(31)).to eq(0xfffffffe)
    expect(IPv4Net.length_to_mask(30)).to eq(0xfffffffc)
    expect(IPv4Net.length_to_mask(29)).to eq(0xfffffff8)
    expect(IPv4Net.length_to_mask(28)).to eq(0xfffffff0)
    expect(IPv4Net.length_to_mask(27)).to eq(0xffffffe0)
    expect(IPv4Net.length_to_mask(26)).to eq(0xffffffc0)
    expect(IPv4Net.length_to_mask(25)).to eq(0xffffff80)
    expect(IPv4Net.length_to_mask(24)).to eq(0xffffff00)
    expect(IPv4Net.length_to_mask(23)).to eq(0xfffffe00)
    expect(IPv4Net.length_to_mask(22)).to eq(0xfffffc00)
    expect(IPv4Net.length_to_mask(21)).to eq(0xfffff800)
    expect(IPv4Net.length_to_mask(20)).to eq(0xfffff000)
    expect(IPv4Net.length_to_mask(19)).to eq(0xffffe000)
    expect(IPv4Net.length_to_mask(18)).to eq(0xffffc000)
    expect(IPv4Net.length_to_mask(17)).to eq(0xffff8000)
    expect(IPv4Net.length_to_mask(16)).to eq(0xffff0000)
    expect(IPv4Net.length_to_mask(15)).to eq(0xfffe0000)
    expect(IPv4Net.length_to_mask(14)).to eq(0xfffc0000)
    expect(IPv4Net.length_to_mask(13)).to eq(0xfff80000)
    expect(IPv4Net.length_to_mask(12)).to eq(0xfff00000)
    expect(IPv4Net.length_to_mask(11)).to eq(0xffe00000)
    expect(IPv4Net.length_to_mask(10)).to eq(0xffc00000)
    expect(IPv4Net.length_to_mask(9)).to eq(0xff800000)
    expect(IPv4Net.length_to_mask(8)).to eq(0xff000000)
    expect(IPv4Net.length_to_mask(7)).to eq(0xfe000000)
    expect(IPv4Net.length_to_mask(6)).to eq(0xfc000000)
    expect(IPv4Net.length_to_mask(5)).to eq(0xf8000000)
    expect(IPv4Net.length_to_mask(4)).to eq(0xf0000000)
    expect(IPv4Net.length_to_mask(3)).to eq(0xe0000000)
    expect(IPv4Net.length_to_mask(2)).to eq(0xc0000000)
    expect(IPv4Net.length_to_mask(1)).to eq(0x80000000)
    expect(IPv4Net.length_to_mask(0)).to eq(0x00000000)
  end
end

end
end
