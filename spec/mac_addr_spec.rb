
require 'ynetaddr'

module Net

describe MacAddr, 'constructor' do
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
end

describe MacAddr, :succ do
  it 'calculates successive address by adding 1 to the NIC ID' do
    expect(MacAddr.new('0012.3456.789a').succ).to eq('0012.3456.789b')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr.new('0012.34ff.ffff').succ }.to raise_error(MacAddr::BadArithmetic)
  end
end

describe MacAddr, :next do
  it 'calculates nextessive address by adding 1 to the NIC ID' do
    expect(MacAddr.new('0012.3456.789a').next).to eq('0012.3456.789b')
  end

  it 'raises an error in case of wrapping NIC ID' do
    expect { MacAddr.new('0012.34ff.ffff').next }.to raise_error(MacAddr::BadArithmetic)
  end
end

describe MacAddr, :unicast? do
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

describe MacAddr, :multicast? do
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

describe MacAddr, :broadcast? do
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

describe MacAddr, :locally_administered? do
  it 'returns true if MacAddress is locally administered' do
    expect(MacAddr.new('0000.3456.789a').locally_administered?).to be_truthy
  end

  it 'returns false if MacAddress is not locally administered' do
    expect(MacAddr.new('f200.3456.789a').locally_administered?).to be_falsey
  end
end

describe MacAddr, :globally_unique? do
  it 'returns true if MacAddress is globally unique' do
    expect(MacAddr.new('f200.3456.789a').globally_unique?).to be_truthy
  end

  it 'returns false if MacAddress is not globally unique' do
    expect(MacAddr.new('0000.3456.789a').globally_unique?).to be_falsey
  end
end

describe MacAddr, :oui do
  it 'extracts correct OUI' do
    expect(MacAddr.new('7423.4567.89ab').oui).to eq(0x742345)
  end
end

describe MacAddr, :<=> do
  it 'correctly compares' do
    expect((MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ab')).to eq(0)
    expect((MacAddr.new('7423.4567.89ab') <=> '7423.4567.89aa')).to eq(1)
    expect((MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ac')).to eq(-1)
  end
end

describe MacAddr, :+ do
  it 'returns of type MacAddr' do
    expect((MacAddr.new('0012.3456.789a') + 1)).to be_an_instance_of(MacAddr)
  end

  it 'sums correctly' do
    expect((MacAddr.new('0012.3456.789a') + 1)).to eq(MacAddr.new('0012.3456.789b'))
    expect((MacAddr.new('0012.3456.789a') + (-1))).to eq(MacAddr.new('0012.3456.7899'))
    expect((MacAddr.new('0012.3456.789a') + 10)).to eq(MacAddr.new('0012.3456.78a4'))
  end
end

describe MacAddr, :- do
  it 'returns of type MacAddr' do
    expect((MacAddr.new('0012.3456.789a') - 1)).to be_an_instance_of(MacAddr)
  end

  it 'subtracts correctly' do
    expect((MacAddr.new('0012.3456.789a') - 1)).to eq(MacAddr.new('0012.3456.7899'))
    expect((MacAddr.new('0012.3456.789a') - (-1))).to eq(MacAddr.new('0012.3456.789b'))
    expect((MacAddr.new('0012.3456.789a') - 10)).to eq(MacAddr.new('0012.3456.7890'))
  end
end

describe MacAddr, :to_s do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s).to eq('00:12:34:56:78:9a')
  end
end

describe MacAddr, :to_s_cisco do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s_cisco).to eq('0012.3456.789a')
  end
end

describe MacAddr, :to_s_dash do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_s_dash).to eq('00-12-34-56-78-9a')
  end
end

describe MacAddr, :to_s_plain do
  it 'outputs the MAC address in plain hexadecimal form' do
    expect(MacAddr.new('0012.3456.789a').to_s_plain).to eq('00123456789a')
  end
end

describe MacAddr, :to_oid do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').to_oid).to eq('0.18.52.86.120.154')
  end
end

describe MacAddr, :hash do
  it 'outputs correctly' do
    expect(MacAddr.new('0012.3456.789a').hash).to eq(0x00123456789a)
  end
end

end
