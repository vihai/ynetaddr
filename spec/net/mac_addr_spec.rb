#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe MacAddr do

describe 'constructor' do
  it 'accepts hhhh.hhhh.hhhh format' do
    expect(MacAddr.new('0012.3456.789a').to_i).to eq(0x00123456789a)
  end

  it 'accepts hh:hh:hh:hh:hh:hh format' do
    expect(MacAddr.new('00:12:34:56:78:9a').to_i).to eq(0x00123456789a)
  end

  it 'accepts integer' do
    expect(MacAddr.new(0x00123456789a).to_i).to eq(0x00123456789a)
  end

  it 'reject invalid empty address' do
    expect { MacAddr.new('') }.to raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { MacAddr.new('0012.3456.fbar') }.to raise_error(ArgumentError)
  end

  it 'takes another MacAddr as input' do
    a = MacAddr.new('0012.3456.fbaa')
    b = MacAddr.new(a)

    expect(b).to eq(a)
  end

  it 'takes a Hash with addr: as usual representation' do
    expect(MacAddr.new(addr: '0012.3456.789a').to_i).to eq(0x00123456789a)
    expect(MacAddr.new(addr: '00:12:34:56:78:9a').to_i).to eq(0x00123456789a)
    expect(MacAddr.new(addr: 0x00123456789a).to_i).to eq(0x00123456789a)
    expect { MacAddr.new(addr: '0012.3456.fbar') }.to raise_error(ArgumentError)

    a = MacAddr.new(addr: '0012.3456.fbaa')
    b = MacAddr.new(addr: a)

    expect(b).to eq(a)
  end

  it 'takes a Hash with binary: key with binary representation' do
    expect(MacAddr.new(binary: "\x00\x11\x22\x33\x44\x55").to_i).to eq(0x001122334455)
  end

  it 'raises a ArgumentError if binary representation is not exactly 6 octets' do
    expect { MacAddr.new(binary: "\x00\x11\x22\x33\x44") }.to raise_error(ArgumentError)
    expect { MacAddr.new(binary: "\x00\x11\x22\x33\x44\x55\x66") }.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { MacAddr.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end
end

describe :succ do
  it 'calculates successive address by adding 1 to the NIC ID' do
    expect(MacAddr.new('0012.3456.789a').succ).to eq('0012.3456.789b')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr.new('0012.34ff.ffff').succ }.to raise_error(MacAddr::BadArithmetic)
  end
end

describe :next do
  it 'calculates nextessive address by adding 1 to the NIC ID' do
    expect(MacAddr.new('0012.3456.789a').next).to eq('0012.3456.789b')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr.new('0012.34ff.ffff').next }.to raise_error(MacAddr::BadArithmetic)
  end
end

describe :unicast? do
  it 'returns true if MacAddress is unicast' do
    expect(MacAddr.new('0012.3456.789a').unicast?).to be_truthy
  end

  it 'returns false if MacAddress is multicast' do
    expect(MacAddr.new('3b12.3456.789a').unicast?).to be_falsey
  end

  it 'returns false if MacAddress is broadcast' do
    expect(MacAddr.new('ffff.ffff.ffff').unicast?).to be_falsey
  end
end

describe :multicast? do
  it 'returns false if MacAddress is unicast' do
    expect(MacAddr.new('0012.3456.789a').multicast?).to be_falsey
  end

  it 'returns true if MacAddress is multicast' do
    expect(MacAddr.new('fb12.3456.789a').multicast?).to be_truthy
  end

  it 'returns false if MacAddress is broadcast' do
    expect(MacAddr.new('ffff.ffff.ffff').multicast?).to be_falsey
  end
end

describe :broadcast? do
  it 'returns false if MacAddress is unicast' do
    expect(MacAddr.new('0012.3456.789a').broadcast?).to be_falsey
  end

  it 'returns false if MacAddress is multicast' do
    expect(MacAddr.new('b012.3456.789a').broadcast?).to be_falsey
  end

  it 'returns true if MacAddress is broadcast' do
    expect(MacAddr.new('ffff.ffff.ffff').broadcast?).to be_truthy
  end
end

describe :locally_administered? do
  it 'returns true if MacAddress is locally administered' do
    expect(MacAddr.new('0000.3456.789a').locally_administered?).to be_truthy
  end

  it 'returns false if MacAddress is not locally administered' do
    expect(MacAddr.new('f200.3456.789a').locally_administered?).to be_falsey
  end
end

describe :globally_unique? do
  it 'returns true if MacAddress is globally unique' do
    expect(MacAddr.new('f200.3456.789a').globally_unique?).to be_truthy
  end

  it 'returns false if MacAddress is not globally unique' do
    expect(MacAddr.new('0000.3456.789a').globally_unique?).to be_falsey
  end
end

describe :oui do
  it 'extracts correct OUI' do
    expect(MacAddr.new('7423.4567.89ab').oui).to eq(0x742345)
  end
end

describe :== do
  it 'returns true if the addresses match' do
    expect(MacAddr.new('7423.4567.89ab') == '7423.4567.89ab').to be_truthy
  end

  it 'returns false if the addresses do not match' do
    expect(MacAddr.new('7423.4567.89ab') == '7423.4567.89aa').to be_falsey
    expect(MacAddr.new('7423.4567.89ab') == '7423.4567.89ac').to be_falsey
  end

  it 'returns false if comparing with nil' do
    expect(MacAddr.new('7423.4567.89ab') == nil).to be_falsey
  end

end

describe :eql? do
  it 'correctly compares' do
    expect(MacAddr.new('7423.4567.89ab').eql?('7423.4567.89ab')).to be_truthy
    expect(MacAddr.new('7423.4567.89ab').eql?('7423.4567.89aa')).to be_falsey
    expect(MacAddr.new('7423.4567.89ab').eql?('7423.4567.89ac')).to be_falsey
  end
end

describe :<=> do
  it 'correctly compares' do
    expect(MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ab').to eq(0)
    expect(MacAddr.new('7423.4567.89ab') <=> '7423.4567.89aa').to eq(1)
    expect(MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ac').to eq(-1)
  end
end

describe :+ do
  it 'returns of type MacAddr' do
    expect(MacAddr.new('0012.3456.789a') + 1).to be_an_instance_of(MacAddr)
  end

  it 'sums correctly' do
    expect(MacAddr.new('0012.3456.789a') + 1).to eq(MacAddr.new('0012.3456.789b'))
    expect(MacAddr.new('0012.3456.789a') + (-1)).to eq(MacAddr.new('0012.3456.7899'))
    expect(MacAddr.new('0012.3456.789a') + 10).to eq(MacAddr.new('0012.3456.78a4'))
  end
end

describe :- do
  it 'returns of type MacAddr' do
    expect(MacAddr.new('0012.3456.789a') - 1).to be_an_instance_of(MacAddr)
  end

  it 'subtracts correctly' do
    expect(MacAddr.new('0012.3456.789a') - 1).to eq(MacAddr.new('0012.3456.7899'))
    expect(MacAddr.new('0012.3456.789a') - (-1)).to eq(MacAddr.new('0012.3456.789b'))
    expect(MacAddr.new('0012.3456.789a') - 10).to eq(MacAddr.new('0012.3456.7890'))
  end
end

describe :to_binary do
  it 'converts to binary representation' do
    expect(MacAddr.new('0012.3456.789a').to_binary).to eq("\x00\x12\x34\x56\x78\x9a".force_encoding(Encoding::ASCII_8BIT))
  end
end

describe :to_s do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s).to eq('00:12:34:56:78:9a')
  end
end

describe :to_s_cisco do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s_cisco).to eq('0012.3456.789a')
  end
end

describe :to_s_dash do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s_dash).to eq('00-12-34-56-78-9a')
  end
end

describe :to_s_plain do
  it 'outputs the MAC address in plain hexadecimal form' do
    expect(MacAddr.new('0012.3456.789a').to_s_plain).to eq('00123456789a')
  end
end

describe :to_oid do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_oid).to eq('0.18.52.86.120.154')
  end
end

describe :hash do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').hash).to eq(0x00123456789a)
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(MacAddr.new('0012.3456.789a').to_json).to eq('"00:12:34:56:78:9a"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(MacAddr.new('0012.3456.789a').to_yaml).to eq("--- 00:12:34:56:78:9a\n")
  end
end

end

end
