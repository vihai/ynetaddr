#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

describe IPv4IfAddr do

describe 'constructor' do
  it 'accepts d.d.d.d/l format' do
    expect(IPv4IfAddr.new('192.168.0.1/24').addr).to eq(0xC0A80001)
    expect(IPv4IfAddr.new('192.168.0.1/24').length).to eq(24)
  end

  it 'rejects network address' do
    expect { IPv4IfAddr.new('10.0.0.0/8') }.to raise_error(ArgumentError)
  end

  it 'rejects broadcast address' do
    expect { IPv4IfAddr.new('10.255.255.255/8') }.to raise_error(ArgumentError)
  end

  it 'reject invalid empty address' do
    expect { IPv4IfAddr.new('') }.to raise_error(ArgumentError)
  end

  it 'reject addr without length' do
    expect { IPv4IfAddr.new('10.0.255.0') }.to raise_error(ArgumentError)
  end

  it 'reject addr with slash but without length' do
    expect { IPv4IfAddr.new('10.0.255.0/') }.to raise_error(ArgumentError)
  end

  it 'reject addr without addr' do
    expect { IPv4IfAddr.new('/24') }.to raise_error(ArgumentError)
  end
end

describe :mask_dotquad do
  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').mask_dotquad).to eq('0.0.0.0')
    expect(IPv4IfAddr.new('10.255.255.1/8').mask_dotquad).to eq('255.0.0.0')
    expect(IPv4IfAddr.new('10.255.255.1/31').mask_dotquad).to eq('255.255.255.254')
    expect(IPv4IfAddr.new('10.255.255.1/32').mask_dotquad).to eq('255.255.255.255')
  end
end

describe :wildcard_dotquad do
  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').wildcard_dotquad).to eq('255.255.255.255')
    expect(IPv4IfAddr.new('10.255.255.1/8').wildcard_dotquad).to eq('0.255.255.255')
    expect(IPv4IfAddr.new('10.255.255.1/31').wildcard_dotquad).to eq('0.0.0.1')
    expect(IPv4IfAddr.new('10.255.255.1/32').wildcard_dotquad).to eq('0.0.0.0')
  end
end

describe :ipclass do
  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('10.0.0.1/8').ipclass).to eq(:a)
    expect(IPv4IfAddr.new('172.16.0.1/12').ipclass).to eq(:b)
    expect(IPv4IfAddr.new('192.168.0.1/16').ipclass).to eq(:c)
    expect(IPv4IfAddr.new('224.0.0.1/32').ipclass).to eq(:d)
    expect(IPv4IfAddr.new('240.0.0.1/32').ipclass).to eq(:e)
  end
end

describe :is_rfc1918? do
  it 'calculates the correct values' do
    expect(IPv4IfAddr.new('0.0.0.1/0').is_rfc1918?).to be_falsey
    expect(IPv4IfAddr.new('1.0.0.1/8').is_rfc1918?).to be_falsey
    expect(IPv4IfAddr.new('10.0.0.1/8').is_rfc1918?).to be_truthy
    expect(IPv4IfAddr.new('172.15.0.1/12').is_rfc1918?).to be_falsey
    expect(IPv4IfAddr.new('172.16.0.1/12').is_rfc1918?).to be_truthy
    expect(IPv4IfAddr.new('192.167.0.1/16').is_rfc1918?).to be_falsey
    expect(IPv4IfAddr.new('192.168.0.1/16').is_rfc1918?).to be_truthy
    expect(IPv4IfAddr.new('192.168.32.1/24').is_rfc1918?).to be_truthy
    expect(IPv4IfAddr.new('192.168.32.1/32').is_rfc1918?).to be_truthy
    expect(IPv4IfAddr.new('192.169.32.1/32').is_rfc1918?).to be_falsey
  end
end

# parent class methods

describe :network do

  it 'is of type IPv4Net' do
    expect(IPv4IfAddr.new('0.0.0.1/0').network).to be_an_instance_of(IPv4Net)
  end

  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').network).to eq(IPv4Net.new('0.0.0.0/0'))
    expect(IPv4IfAddr.new('1.0.0.1/8').network).to eq(IPv4Net.new('1.0.0.0/8'))
    expect(IPv4IfAddr.new('10.0.0.1/8').network).to eq(IPv4Net.new('10.0.0.0/8'))
    expect(IPv4IfAddr.new('172.15.0.1/12').network).to eq(IPv4Net.new('172.15.0.0/12'))
    expect(IPv4IfAddr.new('172.16.0.1/12').network).to eq(IPv4Net.new('172.16.0.0/12'))
    expect(IPv4IfAddr.new('192.167.0.1/16').network).to eq(IPv4Net.new('192.167.0.0/16'))
    expect(IPv4IfAddr.new('192.168.0.1/16').network).to eq(IPv4Net.new('192.168.0.0/16'))
    expect(IPv4IfAddr.new('192.168.32.1/24').network).to eq(IPv4Net.new('192.168.32.0/24'))
    expect(IPv4IfAddr.new('192.168.32.0/31').network).to eq(IPv4Net.new('192.168.32.0/31'))
    expect(IPv4IfAddr.new('192.168.32.1/31').network).to eq(IPv4Net.new('192.168.32.0/31'))
    expect(IPv4IfAddr.new('192.168.32.1/32').network).to eq(IPv4Net.new('192.168.32.1/32'))
    expect(IPv4IfAddr.new('192.169.32.1/32').network).to eq(IPv4Net.new('192.169.32.1/32'))
  end
end

describe :mask do
  it 'is a kind of Integer' do
    expect(IPv4IfAddr.new('0.0.0.1/0').mask).to be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').mask).to eq(0x00000000)
    expect(IPv4IfAddr.new('10.255.255.1/8').mask).to eq(0xff000000)
    expect(IPv4IfAddr.new('10.255.255.1/31').mask).to eq(0xfffffffe)
    expect(IPv4IfAddr.new('10.255.255.1/32').mask).to eq(0xffffffff)
  end
end

describe :wildcard do
  it 'is a kind of Integer' do
    expect(IPv4IfAddr.new('0.0.0.1/0').wildcard).to be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').wildcard).to eq(0xffffffff)
    expect(IPv4IfAddr.new('10.255.255.1/8').wildcard).to eq(0x00ffffff)
    expect(IPv4IfAddr.new('10.255.255.1/31').wildcard).to eq(0x00000001)
    expect(IPv4IfAddr.new('10.255.255.1/32').wildcard).to eq(0x00000000)
  end
end

describe :address do
  it 'is of type IPv4Addr' do
    expect(IPv4IfAddr.new('0.0.0.1/0').address).to be_an_instance_of(IPv4Addr)
  end

  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').address).to eq(IPv4Addr.new('0.0.0.1'))
    expect(IPv4IfAddr.new('1.0.0.1/8').address).to eq(IPv4Addr.new('1.0.0.1'))
    expect(IPv4IfAddr.new('10.0.0.1/8').address).to eq(IPv4Addr.new('10.0.0.1'))
    expect(IPv4IfAddr.new('172.15.0.1/12').address).to eq(IPv4Addr.new('172.15.0.1'))
    expect(IPv4IfAddr.new('172.16.0.1/12').address).to eq(IPv4Addr.new('172.16.0.1'))
    expect(IPv4IfAddr.new('192.167.0.1/16').address).to eq(IPv4Addr.new('192.167.0.1'))
    expect(IPv4IfAddr.new('192.168.0.1/16').address).to eq(IPv4Addr.new('192.168.0.1'))
    expect(IPv4IfAddr.new('192.168.32.1/24').address).to eq(IPv4Addr.new('192.168.32.1'))
    expect(IPv4IfAddr.new('192.168.32.0/31').address).to eq(IPv4Addr.new('192.168.32.0'))
    expect(IPv4IfAddr.new('192.168.32.1/31').address).to eq(IPv4Addr.new('192.168.32.1'))
    expect(IPv4IfAddr.new('192.168.32.1/32').address).to eq(IPv4Addr.new('192.168.32.1'))
    expect(IPv4IfAddr.new('192.169.32.1/32').address).to eq(IPv4Addr.new('192.169.32.1'))
  end
end

describe :nic_id do
  it 'is kind of Integer' do
    expect(IPv4IfAddr.new('0.0.0.1/0').nic_id).to be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').nic_id).to eq(1)
    expect(IPv4IfAddr.new('1.0.0.1/8').nic_id).to eq(1)
    expect(IPv4IfAddr.new('10.0.0.1/8').nic_id).to eq(1)
    expect(IPv4IfAddr.new('172.15.0.1/12').nic_id).to eq(0x000f0001)
    expect(IPv4IfAddr.new('172.16.0.1/12').nic_id).to eq(1)
    expect(IPv4IfAddr.new('192.167.0.1/16').nic_id).to eq(1)
    expect(IPv4IfAddr.new('192.168.0.1/16').nic_id).to eq(1)
    expect(IPv4IfAddr.new('192.168.32.1/24').nic_id).to eq(1)
    expect(IPv4IfAddr.new('192.168.32.0/31').nic_id).to eq(0)
    expect(IPv4IfAddr.new('192.168.32.1/31').nic_id).to eq(1)
    expect(IPv4IfAddr.new('192.168.32.1/32').nic_id).to eq(0)
    expect(IPv4IfAddr.new('192.169.32.1/32').nic_id).to eq(0)
  end
end

describe :include? do
  it 'is correctly calculated' do
    expect(IPv4IfAddr.new('0.0.0.1/0').include?(IPv4Addr.new('1.2.3.4'))).to be_truthy
    expect(IPv4IfAddr.new('0.0.0.1/0').include?(IPv4Addr.new('0.0.0.0'))).to be_truthy
    expect(IPv4IfAddr.new('0.0.0.1/0').include?(IPv4Addr.new('255.255.255.255'))).to be_truthy
    expect(IPv4IfAddr.new('10.0.0.1/8').include?(IPv4Addr.new('9.255.255.255'))).to be_falsey
    expect(IPv4IfAddr.new('10.0.0.1/8').include?(IPv4Addr.new('10.0.0.0'))).to be_truthy
    expect(IPv4IfAddr.new('10.0.0.1/8').include?(IPv4Addr.new('10.255.255.255'))).to be_truthy
    expect(IPv4IfAddr.new('10.0.0.1/8').include?(IPv4Addr.new('11.0.0.0'))).to be_falsey
  end
end

describe :== do
  it 'matches equal interface addresses' do
    expect((IPv4IfAddr.new('0.0.0.1/0') == IPv4IfAddr.new('0.0.0.1/0'))).to be_truthy
    expect((IPv4IfAddr.new('0.0.0.1/0') == IPv4IfAddr.new('4.0.0.1/0'))).to be_falsey
    expect((IPv4IfAddr.new('10.0.0.1/8') == IPv4IfAddr.new('10.0.0.1/8'))).to be_truthy
    expect((IPv4IfAddr.new('192.168.255.254/24') == IPv4IfAddr.new('192.168.255.254/24'))).to be_truthy
    expect((IPv4IfAddr.new('192.168.255.255/32') == IPv4IfAddr.new('192.168.255.255/32'))).to be_truthy
  end
end

describe :to_s do
  it 'produces correct output' do
    expect(IPv4IfAddr.new('0.0.0.1/0').to_s).to eq('0.0.0.1/0')
    expect(IPv4IfAddr.new('10.0.0.1/8').to_s).to eq('10.0.0.1/8')
    expect(IPv4IfAddr.new('192.168.255.254/24').to_s).to eq('192.168.255.254/24')
    expect(IPv4IfAddr.new('192.168.255.255/32').to_s).to eq('192.168.255.255/32')
  end
end

describe :to_hash do
  it 'produces correct output' do
    expect(IPv4IfAddr.new('0.0.0.1/0').to_hash).to eq({ :addr => 0x00000001, :length => 0 })
    expect(IPv4IfAddr.new('10.0.0.1/8').to_hash).to eq({ :addr => 0x0a000001, :length => 8 })
    expect(IPv4IfAddr.new('192.168.255.254/24').to_hash).to eq({ :addr => 0xc0a8fffe, :length => 24 })
    expect(IPv4IfAddr.new('192.168.255.255/32').to_hash).to eq({ :addr => 0xc0a8ffff, :length => 32 })
  end
end

end

end
