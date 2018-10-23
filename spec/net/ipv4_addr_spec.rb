#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv4Addr do

describe 'constructor' do
  it 'accepts d.d.d.d format' do
    expect(IPv4Addr.new('1.2.0.255').to_i).to eq(0x010200ff)
  end

  it 'accepts [d.d.d.d] format' do
    expect(IPv4Addr.new('[1.2.0.255]').to_i).to eq(0x010200ff)
  end

  it 'accepts integer' do
    expect(IPv4Addr.new(0x01020304).to_i).to eq(0x01020304)
  end

  it 'accepts hash[:addr]' do
    expect(IPv4Addr.new(addr: '1.2.0.255').to_i).to eq(0x010200ff)
    expect(IPv4Addr.new(addr: 0x01020304).to_i).to eq(0x01020304)
  end

  it 'accepts hash[:binary]' do
    expect(IPv4Addr.new(binary: 'AEIO').to_i).to eq(0x4145494f)
  end

  it 'rejects a wrong size binary addr' do
    expect { IPv4Addr.new(binary: 'AEIOU') }.to raise_error(ArgumentError)
    expect { IPv4Addr.new(binary: 'AEI') }.to raise_error(ArgumentError)
  end


#  it 'accept d.d.d format' do
#    expect(IPv4Addr.new('1.2.65530').to_i).to eq(16908543)
#  end
#
#  it 'accept d.d format' do
#    expect(IPv4Addr.new('1.5487554').to_i).to eq(16908543)
#  end
#
#  it 'accept d format' do
#    expect(IPv4Addr.new('16908543').to_i).to eq(16908543)
#  end

#  it 'reject invalid octet (>255) values' do
#    expect { IPv4Addr.new('1.2.0.256') }.to raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d.d' do
#    expect { IPv4Addr.new('1.2.65536') }.to raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d' do
#    expect { IPv4Addr.new('1.2.16777216') }.to raise_error(ArgumentError)
#  end

  it 'reject invalid empty address' do
    expect { IPv4Addr.new('') }.to raise_error(ArgumentError)
  end

  it 'reject invalid empty [] address' do
    expect { IPv4Addr.new('[]') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { IPv4Addr.new('foo') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { IPv4Addr.new('[foo]') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { IPv4Addr.new('1.2.3.0foo') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { IPv4Addr.new('1.2.3.f0') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { IPv4Addr.new('1.2.3.f0') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with consecutive dots' do
    expect { IPv4Addr.new('1.2..4') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with negative components' do
    expect { IPv4Addr.new('1.2.-3.4') }.to raise_error(ArgumentError)
  end

end

describe :to_binary do
  it 'returns a binary string representation of the IP address' do
    expect(IPv4Addr.new('11.22.33.44').to_binary).to eq(
      "\x0b\x16\x21\x2c".force_encoding(Encoding::ASCII_8BIT))
  end
end

describe :reverse do
  it 'produces reverse mapping name' do
    expect(IPv4Addr.new('1.200.3.255').reverse).to eq('255.3.200.1.in-addr.arpa')
  end
end

describe :is_rfc1918? do
  it 'returns true for RF1918 addresses' do
    expect(IPv4Addr.new('10.0.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('10.1.2.3').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('10.255.255.255').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.1.2').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.255.255').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.16.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.16.1.2').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.31.255.255').is_rfc1918?).to be_truthy
  end

  it 'returns false for RF1918 addresses' do
    expect(IPv4Addr.new('9.255.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('11.0.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('192.167.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('192.169.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('172.15.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('172.32.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('224.0.0.0').is_rfc1918?).to be_falsey
  end
end

describe :ipclass do
  it 'returns the correct class' do
    expect(IPv4Addr.new('0.0.0.0').ipclass).to eq(:a)
    expect(IPv4Addr.new('10.0.0.0').ipclass).to eq(:a)
    expect(IPv4Addr.new('127.255.255.255').ipclass).to eq(:a)
    expect(IPv4Addr.new('128.0.0.0').ipclass).to eq(:b)
    expect(IPv4Addr.new('172.16.0.0').ipclass).to eq(:b)
    expect(IPv4Addr.new('191.255.255.255').ipclass).to eq(:b)
    expect(IPv4Addr.new('192.0.0.0').ipclass).to eq(:c)
    expect(IPv4Addr.new('192.168.0.0').ipclass).to eq(:c)
    expect(IPv4Addr.new('223.255.255.255').ipclass).to eq(:c)
    expect(IPv4Addr.new('224.0.0.0').ipclass).to eq(:d)
    expect(IPv4Addr.new('224.1.2.3').ipclass).to eq(:d)
    expect(IPv4Addr.new('239.255.255.255').ipclass).to eq(:d)
    expect(IPv4Addr.new('240.0.0.0').ipclass).to eq(:e)
    expect(IPv4Addr.new('245.0.0.0').ipclass).to eq(:e)
    expect(IPv4Addr.new('255.255.255.255').ipclass).to eq(:e)
  end
end

describe :unicast? do
  it 'returns true if the address is unicast' do
    expect(IPv4Addr.new('0.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('10.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('127.255.255.255').unicast?).to eq(true)
    expect(IPv4Addr.new('128.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('172.16.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('191.255.255.255').unicast?).to eq(true)
    expect(IPv4Addr.new('192.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('192.168.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('223.255.255.255').unicast?).to eq(true)
  end

  it 'returns false if the address is not unicast' do
    expect(IPv4Addr.new('224.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('224.1.2.3').unicast?).to eq(false)
    expect(IPv4Addr.new('239.255.255.255').unicast?).to eq(false)
    expect(IPv4Addr.new('240.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('245.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('255.255.255.255').unicast?).to eq(false)
  end
end

describe :multicast? do
  it 'returns true if the address is multicast' do
    expect(IPv4Addr.new('224.0.0.0').multicast?).to eq(true)
    expect(IPv4Addr.new('224.1.2.3').multicast?).to eq(true)
    expect(IPv4Addr.new('239.255.255.255').multicast?).to eq(true)
  end

  it 'returns false if address is not multicast' do
    expect(IPv4Addr.new('0.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('10.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('127.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('128.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('172.16.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('191.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('192.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('192.168.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('223.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('240.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('245.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('255.255.255.255').multicast?).to eq(false)
  end
end

describe :to_s do
  it 'produces correct output for addresses starting with 0' do
    expect(IPv4Addr.new('0.0.0.0').to_s).to eq('0.0.0.0')
  end
end

describe :to_s_bracketed do
  it 'produces bracketed output' do
    expect(IPv4Addr.new('1.2.3.4').to_s_bracketed).to eq('[1.2.3.4]')
  end
end


# Parent-class methods

describe :included_in? do
  it 'calculates the correct values' do
    expect(IPv4Addr.new('1.2.3.4').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.0').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('255.255.255.255').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('9.255.255.255').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect(IPv4Addr.new('10.0.0.0').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_truthy
    expect(IPv4Addr.new('10.255.255.255').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_truthy
    expect(IPv4Addr.new('11.0.0.0').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_falsey
  end
end

describe :succ do
  it 'returns a IPv4Addr' do
    expect(IPv4Addr.new('1.2.3.4').succ).to be_an_instance_of(IPv4Addr)
  end

  it 'return successive IP address by adding 1' do
    expect(IPv4Addr.new('1.2.3.4').succ).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('192.168.255.255').succ).to eq(IPv4Addr.new('192.169.0.0'))
  end
end

describe :next do
  it 'returns a IPv4Addr' do
    expect(IPv4Addr.new('1.2.3.4').next).to be_an_instance_of(IPv4Addr)
  end

  it 'return successive IP address by adding 1' do
    expect(IPv4Addr.new('1.2.3.4').next).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('192.168.255.255').next).to eq(IPv4Addr.new('192.169.0.0'))
  end
end

describe :== do
  it 'return true for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('1.2.3.4')).to be_truthy
    expect(IPv4Addr.new('0.0.0.0') == IPv4Addr.new('0.0.0.0')).to be_truthy
    expect(IPv4Addr.new('0.0.0.1') == IPv4Addr.new('0.0.0.1')).to be_truthy
    expect(IPv4Addr.new('255.255.255.255') == IPv4Addr.new('255.255.255.255')).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('0.0.0.0')).to be_falsey
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('255.255.255.255')).to be_falsey
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('1.2.3.5')).to be_falsey
    expect(IPv4Addr.new('0.0.0.0') == IPv4Addr.new('255.255.255.255')).to be_falsey
    expect(IPv4Addr.new('255.255.255.255') == IPv4Addr.new('0.0.0.0')).to be_falsey
  end
end

describe :eql? do
  it 'return true for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('1.2.3.4'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.0').eql?(IPv4Addr.new('0.0.0.0'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.1').eql?(IPv4Addr.new('0.0.0.1'))).to be_truthy
    expect(IPv4Addr.new('255.255.255.255').eql?(IPv4Addr.new('255.255.255.255'))).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('0.0.0.0'))).to be_falsey
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('255.255.255.255'))).to be_falsey
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('1.2.3.5'))).to be_falsey
    expect(IPv4Addr.new('0.0.0.0').eql?(IPv4Addr.new('255.255.255.255'))).to be_falsey
    expect(IPv4Addr.new('255.255.255.255').eql?(IPv4Addr.new('0.0.0.0'))).to be_falsey
  end
end

describe '!=' do
  it 'returns true for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('255.255.255.255')).to be_truthy
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('1.2.3.5')).to be_truthy
    expect(IPv4Addr.new('0.0.0.0') != IPv4Addr.new('255.255.255.255')).to be_truthy
    expect(IPv4Addr.new('255.255.255.255') != IPv4Addr.new('0.0.0.0')).to be_truthy
  end

  it 'returns false for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('1.2.3.4')).to be_falsey
    expect(IPv4Addr.new('0.0.0.0') != IPv4Addr.new('0.0.0.0')).to be_falsey
    expect(IPv4Addr.new('0.0.0.1') != IPv4Addr.new('0.0.0.1')).to be_falsey
    expect(IPv4Addr.new('255.255.255.255') != IPv4Addr.new('255.255.255.255')).to be_falsey
    expect((IPv4Addr.new('1.2.3.4') != IPv4Addr.new('0.0.0.0'))).to be_truthy
  end
end

describe :<=> do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.4')).to be_a_kind_of(Integer)
  end

  it 'compares correctly' do
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.4')).to eq(0)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.5')).to eq(-1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.3')).to eq(1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('0.0.0.0')).to eq(1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('255.255.255.255')).to eq(-1)
  end
end

describe :+ do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new('1.2.3.4') + 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'sums correctly' do
    expect(IPv4Addr.new('1.2.3.4') + 1).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('1.2.3.4') + (-1)).to eq(IPv4Addr.new('1.2.3.3'))
    expect(IPv4Addr.new('1.2.3.4') + 10).to eq(IPv4Addr.new('1.2.3.14'))
  end
end

describe :- do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new('1.2.3.4') - 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'subtracts Fixnum from address' do
    expect((IPv4Addr.new('1.2.3.4') - 1)).to eq(IPv4Addr.new('1.2.3.3'))
    expect((IPv4Addr.new('1.2.3.4') - (-1))).to eq(IPv4Addr.new('1.2.3.5'))
    expect((IPv4Addr.new('1.2.3.4') - 10)).to eq(IPv4Addr.new('1.2.2.250'))
  end

  it 'subtracts IPv4Addr from address' do
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.2')).to eq(2)
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.4')).to eq(0)
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.6')).to eq(-2)
  end
end

describe :| do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x00000000) | 0x0000ffff)).to be_an_instance_of(IPv4Addr)
  end

  it 'operates correctly'do
    expect((IPv4Addr.new(0x00000000) | 0x0000ffff)).to eq(0x0000ffff)
  end
end

describe :& do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff)).to be_an_instance_of(IPv4Addr)
  end

  it 'operates correctly' do
    expect((IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff)).to eq(0x00000f0f)
  end
end

describe :mask do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000))).to be_an_instance_of(IPv4Addr)
  end

  it 'masks correctly' do
    expect((IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000))).to eq(0x0f0f0000)
  end
end

describe :mask! do
  it 'returns self' do
    a = IPv4Addr.new('1.2.3.4')
    expect(a.mask!(0xffff0000)).to be_equal(a)
  end

  it 'masks correctly' do
    a = IPv4Addr.new(0x0f0f0f0f)
    expect(a.to_i).to eq(0x0f0f0f0f)
    a.mask!(0xffff0000)
    expect(a.to_i).to eq(0x0f0f0000)
  end
end

describe :to_i do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4').to_i).to be_a_kind_of(Integer)
  end

  it 'converts to integer' do
    expect(IPv4Addr.new(0x0f0f0f0f).to_i).to eq(0x0f0f0f0f)
  end
end

describe :hash do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4').hash).to be_a_kind_of(Integer)
  end

  it 'produces a hash' do
    expect(IPv4Addr.new(0x0f0f0f0f).to_i).to eq(0x0f0f0f0f)
  end
end

describe :as_json do
  it 'returns a representation for to_json' do
    expect(IPv4Addr.new('1.2.3.4').as_json).to eq('1.2.3.4')
  end
end

end

end
