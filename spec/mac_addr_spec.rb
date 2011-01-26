
require 'ynetaddr'

describe Net::MacAddr, 'constructor' do
  it 'accepts hhhh.hhhh.hhhh format' do
    Net::MacAddr.new('0012.3456.789a').to_i.should == 0x00123456789a
  end

  it 'accepts hh:hh:hh:hh:hh:hh format' do
    Net::MacAddr.new('00:12:34:56:78:9a').to_i.should == 0x00123456789a
  end

  it 'accepts integer' do
    Net::MacAddr.new(0x00123456789a).to_i.should == 0x00123456789a
  end

  it 'reject invalid empty address' do
    lambda { Net::MacAddr.new('') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::MacAddr.new('0012.3456.fbar') }.should raise_error(ArgumentError)
  end
end

describe Net::MacAddr, :succ do
  it 'calculates successive' do
    Net::MacAddr.new('0012.3456.789a').succ.should == '0012.3456.789b'
  end

  it 'raises an error in case of wrapping NIC ID' do
    lambda { Net::MacAddr.new('0012.34ff.ffff').succ }.should raise_error(Net::MacAddr::BadArithmetic)
  end
end

describe Net::MacAddr, :unicast? do
  it 'returns true if MacAddress is unicast' do
    Net::MacAddr.new('0012.3456.789a').unicast?.should be_true
  end

  it 'returns false if MacAddress is multicast' do
    Net::MacAddr.new('3b12.3456.789a').unicast?.should be_false
  end

  it 'returns false if MacAddress is broadcast' do
    Net::MacAddr.new('ffff.ffff.ffff').unicast?.should be_false
  end
end

describe Net::MacAddr, :multicast? do
  it 'returns false if MacAddress is unicast' do
    Net::MacAddr.new('0012.3456.789a').multicast?.should be_false
  end

  it 'returns true if MacAddress is multicast' do
    Net::MacAddr.new('fb12.3456.789a').multicast?.should be_true
  end

  it 'returns false if MacAddress is broadcast' do
    Net::MacAddr.new('ffff.ffff.ffff').multicast?.should be_false
  end
end

describe Net::MacAddr, :broadcast? do
  it 'returns false if MacAddress is unicast' do
    Net::MacAddr.new('0012.3456.789a').broadcast?.should be_false
  end

  it 'returns false if MacAddress is multicast' do
    Net::MacAddr.new('b012.3456.789a').broadcast?.should be_false
  end

  it 'returns true if MacAddress is broadcast' do
    Net::MacAddr.new('ffff.ffff.ffff').broadcast?.should be_true
  end
end

describe Net::MacAddr, :locally_administered? do
  it 'returns true if MacAddress is locally administered' do
    Net::MacAddr.new('0000.3456.789a').locally_administered?.should be_true
  end

  it 'returns false if MacAddress is not locally administered' do
    Net::MacAddr.new('f200.3456.789a').locally_administered?.should be_false
  end
end

describe Net::MacAddr, :globally_unique? do
  it 'returns true if MacAddress is globally unique' do
    Net::MacAddr.new('f200.3456.789a').globally_unique?.should be_true
  end

  it 'returns false if MacAddress is not globally unique' do
    Net::MacAddr.new('0000.3456.789a').globally_unique?.should be_false
  end
end

describe Net::MacAddr, :oui do
  it 'extracts correct OUI' do
    Net::MacAddr.new('7423.4567.89ab').oui.should == 0x742345
  end
end

describe Net::MacAddr, :<=> do
  it 'correctly compares' do
    (Net::MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ab').should == 0
    (Net::MacAddr.new('7423.4567.89ab') <=> '7423.4567.89aa').should == 1
    (Net::MacAddr.new('7423.4567.89ab') <=> '7423.4567.89ac').should == -1
  end
end

describe Net::MacAddr, :+ do
  it 'returns of type Net::MacAddr' do
    (Net::MacAddr.new('0012.3456.789a') + 1).should be_an_instance_of(Net::MacAddr)
  end

  it 'sums correctly' do
    (Net::MacAddr.new('0012.3456.789a') + 1).should == Net::MacAddr.new('0012.3456.789b')
    (Net::MacAddr.new('0012.3456.789a') + (-1)).should == Net::MacAddr.new('0012.3456.7899')
    (Net::MacAddr.new('0012.3456.789a') + 10).should == Net::MacAddr.new('0012.3456.78a4')
  end
end

describe Net::MacAddr, :- do
  it 'returns of type Net::MacAddr' do
    (Net::MacAddr.new('0012.3456.789a') - 1).should be_an_instance_of(Net::MacAddr)
  end

  it 'subtracts correctly' do
    (Net::MacAddr.new('0012.3456.789a') - 1).should == Net::MacAddr.new('0012.3456.7899')
    (Net::MacAddr.new('0012.3456.789a') - (-1)).should == Net::MacAddr.new('0012.3456.789b')
    (Net::MacAddr.new('0012.3456.789a') - 10).should == Net::MacAddr.new('0012.3456.7890')
  end
end

describe Net::MacAddr, :to_s do
  it 'outputs correctly' do
    Net::MacAddr.new('0012.3456.789a').to_s.should == '00:12:34:56:78:9a'
  end
end

describe Net::MacAddr, :to_s_cisco do
  it 'outputs correctly' do
    Net::MacAddr.new('0012.3456.789a').to_s_cisco.should == '0012.3456.789a'
  end
end

describe Net::MacAddr, :to_s_dash do
  it 'outputs correctly' do
    Net::MacAddr.new('0012.3456.789a').to_s_dash.should == '00-12-34-56-78-9a'
  end
end

describe Net::MacAddr, :to_oid do
  it 'outputs correctly' do
    Net::MacAddr.new('0012.3456.789a').to_oid.should == '0.18.52.86.120.154'
  end
end

describe Net::MacAddr, :hash do
  it 'outputs correctly' do
    Net::MacAddr.new('0012.3456.789a').hash.should == 0x00123456789a
  end
end
