#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe MacAddr64 do

describe 'constructor' do
  it 'accepts hhhh.hhhh.hhhh.hhhh format' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_i).to eq(0x00123456789abcde)
  end

  it 'accepts hh:hh:hh:hh:hh:hh:hh:hh format' do
    expect(MacAddr64.new('00:12:34:56:78:9a:bc:de').to_i).to eq(0x00123456789abcde)
  end

  it 'accepts integer' do
    expect(MacAddr64.new(0x00123456789abcde).to_i).to eq(0x00123456789abcde)
  end

  it 'reject invalid empty address' do
    expect { MacAddr64.new('') }.to raise_error(FormatNotRecognized)
  end

  it 'reject invalid address with alphanumeric chars' do
    expect { MacAddr64.new('0012.3456.789a.fbar') }.to raise_error(FormatNotRecognized)
  end

  it 'takes another MacAddr64 as input' do
    a = MacAddr64.new('0012.3456.789a.bcde')
    b = MacAddr64.new(a)

    expect(b).to eq(a)
  end

  it 'takes a Hash with addr: as usual representation' do
    expect(MacAddr64.new(addr: '0012.3456.789a.bcde').to_i).to eq(0x00123456789abcde)
    expect(MacAddr64.new(addr: '00:12:34:56:78:9a:bc:de').to_i).to eq(0x00123456789abcde)
    expect(MacAddr64.new(addr: 0x00123456789abcde).to_i).to eq(0x00123456789abcde)
    expect { MacAddr64.new(addr: '0012.3456.789a.fbar') }.to raise_error(ArgumentError)

    a = MacAddr64.new(addr: '0012.3456.bcde.fbaa')
    b = MacAddr64.new(addr: a)

    expect(b).to eq(a)
  end

  it 'takes a Hash with binary: key with binary representation' do
    expect(MacAddr64.new(binary: "\x00\x11\x22\x33\x44\x55\x66\x77").to_i).to eq(0x0011223344556677)
  end

  it 'raises a ArgumentError if binary representation is not exactly 8 octets' do
    expect { MacAddr64.new(binary: "\x00\x11\x22\x33\x44\x55\x66") }.to raise_error(ArgumentError)
    expect { MacAddr64.new(binary: "\x00\x11\x22\x33\x44\x55\x66\x77\x88") }.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { MacAddr64.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end
end

describe :succ do
  it 'calculates successive address by adding 1 to the NIC ID' do
    expect(MacAddr64.new('0012.3456.789a.bcde').succ).to eq('0012.3456.789a.bcdf')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr64.new('0012.34ff.ffff.ffff').succ }.to raise_error(MacAddr64::BadArithmetic)
  end
end

describe :next do
  it 'calculates successive address by adding 1 to the NIC ID' do
    expect(MacAddr64.new('0012.3456.789a.bcde').next).to eq('0012.3456.789a.bcdf')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr64.new('0012.34ff.ffff.ffff').next }.to raise_error(MacAddr64::BadArithmetic)
  end
end

describe :unicast? do
  it 'returns true if MacAddr64ess is unicast' do
    expect(MacAddr64.new('0012.3456.789a.bcde').unicast?).to be_truthy
  end

  it 'returns false if MacAddr64ess is multicast' do
    expect(MacAddr64.new('3b12.3456.789a.bcde').unicast?).to be_falsey
  end

  it 'returns false if MacAddr64ess is broadcast' do
    expect(MacAddr64.new('ffff.ffff.ffff.ffff').unicast?).to be_falsey
  end
end

describe :multicast? do
  it 'returns false if MacAddr64ess is unicast' do
    expect(MacAddr64.new('0012.3456.789a.bcde').multicast?).to be_falsey
  end

  it 'returns true if MacAddr64ess is multicast' do
    expect(MacAddr64.new('fb12.3456.789a.bcde').multicast?).to be_truthy
  end

  it 'returns false if MacAddr64ess is broadcast' do
    expect(MacAddr64.new('ffff.ffff.ffff.ffff').multicast?).to be_falsey
  end
end

describe :broadcast? do
  it 'returns false if MacAddr64ess is unicast' do
    expect(MacAddr64.new('0012.3456.789a.bcde').broadcast?).to be_falsey
  end

  it 'returns false if MacAddr64ess is multicast' do
    expect(MacAddr64.new('b012.3456.789a.bcde').broadcast?).to be_falsey
  end

  it 'returns true if MacAddr64ess is broadcast' do
    expect(MacAddr64.new('ffff.ffff.ffff.ffff').broadcast?).to be_truthy
  end
end

describe :locally_administered? do
  it 'returns true if MacAddr64ess is locally administered' do
    expect(MacAddr64.new('0000.3456.789a.bcde').locally_administered?).to be_truthy
  end

  it 'returns false if MacAddr64ess is not locally administered' do
    expect(MacAddr64.new('f200.3456.789a.bcde').locally_administered?).to be_falsey
  end
end

describe :globally_unique? do
  it 'returns true if MacAddr64ess is globally unique' do
    expect(MacAddr64.new('f200.3456.789a.bcde').globally_unique?).to be_truthy
  end

  it 'returns false if MacAddr64ess is not globally unique' do
    expect(MacAddr64.new('0000.3456.789a.bcde').globally_unique?).to be_falsey
  end
end

describe :oui do
  it 'extracts correct OUI' do
    expect(MacAddr64.new('7423.4567.89ab.cdef').oui).to eq(0x742345)
  end
end

describe :== do
  it 'returns true if the addresses match' do
    expect(MacAddr64.new('7423.4567.89ab.bcde') == '7423.4567.89ab.bcde').to be_truthy
  end

  it 'returns false if the addresses do not match' do
    expect(MacAddr64.new('7423.4567.89ab.bcde') == '7423.4567.89aa.bcde').to be_falsey
    expect(MacAddr64.new('7423.4567.89ab.bcde') == '7423.4567.89ac.bcde').to be_falsey
  end

  it 'returns false if comparing with nil' do
    expect(MacAddr64.new('7423.4567.89ab.bcde') == nil).to be_falsey
  end

end

describe :eql? do
  it 'correctly compares' do
    expect(MacAddr64.new('7423.4567.89ab.bcde').eql?('7423.4567.89ab.bcde')).to be_truthy
    expect(MacAddr64.new('7423.4567.89ab.bcde').eql?('7423.4567.89aa.bcde')).to be_falsey
    expect(MacAddr64.new('7423.4567.89ab.bcde').eql?('7423.4567.89ac.bcde')).to be_falsey
  end
end

describe :<=> do
  it 'correctly compares' do
    expect(MacAddr64.new('7423.4567.89ab.bcde') <=> '7423.4567.89ab.bcde').to eq(0)
    expect(MacAddr64.new('7423.4567.89ab.bcde') <=> '7423.4567.89aa.bcde').to eq(1)
    expect(MacAddr64.new('7423.4567.89ab.bcde') <=> '7423.4567.89ac.bcde').to eq(-1)
  end
end

describe :+ do
  it 'returns of type MacAddr64' do
    expect(MacAddr64.new('0012.3456.789a.bcde') + 1).to be_an_instance_of(MacAddr64)
  end

  it 'sums correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde') + 1).to eq(MacAddr64.new('0012.3456.789a.bcdf'))
    expect(MacAddr64.new('0012.3456.789a.bcde') + (-1)).to eq(MacAddr64.new('0012.3456.789a.bcdd'))
    expect(MacAddr64.new('0012.3456.789a.bcde') + 10).to eq(MacAddr64.new('0012.3456.789a.bce8'))
  end
end

describe :- do
  it 'returns of type MacAddr64' do
    expect(MacAddr64.new('0012.3456.789a.bcde') - 1).to be_an_instance_of(MacAddr64)
  end

  it 'subtracts correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde') - 1).to eq(MacAddr64.new('0012.3456.789a.bcdd'))
    expect(MacAddr64.new('0012.3456.789a.bcde') - (-1)).to eq(MacAddr64.new('0012.3456.789a.bcdf'))
    expect(MacAddr64.new('0012.3456.789a.bcde') - 10).to eq(MacAddr64.new('0012.3456.789a.bcd4'))
  end
end

describe :to_binary do
  it 'converts to binary representation' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_binary).to eq("\x00\x12\x34\x56\x78\x9a\xbc\xde".b)
  end
end

describe :to_s do
  it 'outputs correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_s).to eq('00:12:34:56:78:9a:bc:de')
  end
end

describe :to_s_cisco do
  it 'outputs correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_s_cisco).to eq('0012.3456.789a.bcde')
  end
end

describe :to_s_dash do
  it 'outputs correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_s_dash).to eq('00-12-34-56-78-9a-bc-de')
  end
end

describe :to_s_plain do
  it 'outputs the MAC address in plain hexadecimal form' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_s_plain).to eq('00123456789abcde')
  end
end

describe :to_oid do
  it 'outputs correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_oid).to eq('52.86.120.154.188.222.0.0')
  end
end

describe :hash do
  it 'outputs correctly' do
    expect(MacAddr64.new('0012.3456.789a.bcde').hash).to eq(0x00123456789abcde)
  end
end

describe :to_json do
  it 'returns a representation for to_json' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_json).to eq('"00:12:34:56:78:9a:bc:de"')
  end
end

describe :to_yaml do
  it 'returns a representation for to_yaml' do
    expect(MacAddr64.new('0012.3456.789a.bcde').to_yaml).to eq("--- 00:12:34:56:78:9a:bc:de\n")
  end
end

end

end
