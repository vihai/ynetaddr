
require 'ynetaddr'

describe Net::IPv4IfAddr, 'constructor' do
  it 'accepts d.d.d.d/l format' do
    Net::IPv4IfAddr.new('192.168.0.1/24').addr.should == 0xC0A80001
    Net::IPv4IfAddr.new('192.168.0.1/24').length.should == 24
  end

  it 'rejects network address' do
    lambda { Net::IPv4IfAddr.new('10.0.0.0/8') }.should raise_error(ArgumentError)
  end

  it 'rejects broadcast address' do
    lambda { Net::IPv4IfAddr.new('10.255.255.255/8') }.should raise_error(ArgumentError)
  end

  it 'reject invalid empty address' do
    lambda { Net::IPv4IfAddr.new('') }.should raise_error(ArgumentError)
  end

  it 'reject addr without length' do
    lambda { Net::IPv4IfAddr.new('10.0.255.0') }.should raise_error(ArgumentError)
  end

  it 'reject addr with slash but without length' do
    lambda { Net::IPv4IfAddr.new('10.0.255.0/') }.should raise_error(ArgumentError)
  end

  it 'reject addr without addr' do
    lambda { Net::IPv4IfAddr.new('/24') }.should raise_error(ArgumentError)
  end
end

describe Net::IPv4IfAddr, :mask_dotquad do
  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').mask_dotquad.should == '0.0.0.0'
    Net::IPv4IfAddr.new('10.255.255.1/8').mask_dotquad.should == '255.0.0.0'
    Net::IPv4IfAddr.new('10.255.255.1/31').mask_dotquad.should == '255.255.255.254'
    Net::IPv4IfAddr.new('10.255.255.1/32').mask_dotquad.should == '255.255.255.255'
  end
end

describe Net::IPv4IfAddr, :wildcard_dotquad do
  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').wildcard_dotquad.should == '255.255.255.255'
    Net::IPv4IfAddr.new('10.255.255.1/8').wildcard_dotquad.should == '0.255.255.255'
    Net::IPv4IfAddr.new('10.255.255.1/31').wildcard_dotquad.should == '0.0.0.1'
    Net::IPv4IfAddr.new('10.255.255.1/32').wildcard_dotquad.should == '0.0.0.0'
  end
end

describe Net::IPv4IfAddr, :ipclass do
  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('10.0.0.1/8').ipclass.should == :a
    Net::IPv4IfAddr.new('172.16.0.1/12').ipclass.should == :b
    Net::IPv4IfAddr.new('192.168.0.1/16').ipclass.should == :c
    Net::IPv4IfAddr.new('224.0.0.1/32').ipclass.should == :d
    Net::IPv4IfAddr.new('240.0.0.1/32').ipclass.should == :e
  end
end

describe Net::IPv4IfAddr, :is_rfc1918? do
  it 'calculates the correct values' do
    Net::IPv4IfAddr.new('0.0.0.1/0').is_rfc1918?.should be_false
    Net::IPv4IfAddr.new('1.0.0.1/8').is_rfc1918?.should be_false
    Net::IPv4IfAddr.new('10.0.0.1/8').is_rfc1918?.should be_true
    Net::IPv4IfAddr.new('172.15.0.1/12').is_rfc1918?.should be_false
    Net::IPv4IfAddr.new('172.16.0.1/12').is_rfc1918?.should be_true
    Net::IPv4IfAddr.new('192.167.0.1/16').is_rfc1918?.should be_false
    Net::IPv4IfAddr.new('192.168.0.1/16').is_rfc1918?.should be_true
    Net::IPv4IfAddr.new('192.168.32.1/24').is_rfc1918?.should be_true
    Net::IPv4IfAddr.new('192.168.32.1/32').is_rfc1918?.should be_true
    Net::IPv4IfAddr.new('192.169.32.1/32').is_rfc1918?.should be_false
  end
end

# parent class methods

describe Net::IPv4IfAddr, :network do

  it 'is of type Net::IPv4Net' do
    Net::IPv4IfAddr.new('0.0.0.1/0').network.should be_an_instance_of(Net::IPv4Net)
  end

  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').network.should == Net::IPv4Net.new('0.0.0.0/0')
    Net::IPv4IfAddr.new('1.0.0.1/8').network.should == Net::IPv4Net.new('1.0.0.0/8')
    Net::IPv4IfAddr.new('10.0.0.1/8').network.should == Net::IPv4Net.new('10.0.0.0/8')
    Net::IPv4IfAddr.new('172.15.0.1/12').network.should == Net::IPv4Net.new('172.15.0.0/12')
    Net::IPv4IfAddr.new('172.16.0.1/12').network.should == Net::IPv4Net.new('172.16.0.0/12')
    Net::IPv4IfAddr.new('192.167.0.1/16').network.should == Net::IPv4Net.new('192.167.0.0/16')
    Net::IPv4IfAddr.new('192.168.0.1/16').network.should == Net::IPv4Net.new('192.168.0.0/16')
    Net::IPv4IfAddr.new('192.168.32.1/24').network.should == Net::IPv4Net.new('192.168.32.0/24')
    Net::IPv4IfAddr.new('192.168.32.0/31').network.should == Net::IPv4Net.new('192.168.32.0/31')
    Net::IPv4IfAddr.new('192.168.32.1/31').network.should == Net::IPv4Net.new('192.168.32.0/31')
    Net::IPv4IfAddr.new('192.168.32.1/32').network.should == Net::IPv4Net.new('192.168.32.1/32')
    Net::IPv4IfAddr.new('192.169.32.1/32').network.should == Net::IPv4Net.new('192.169.32.1/32')
  end
end

describe Net::IPv4IfAddr, :mask do
  it 'is a kind of Integer' do
    Net::IPv4IfAddr.new('0.0.0.1/0').mask.should be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').mask.should == 0x00000000
    Net::IPv4IfAddr.new('10.255.255.1/8').mask.should == 0xff000000
    Net::IPv4IfAddr.new('10.255.255.1/31').mask.should == 0xfffffffe
    Net::IPv4IfAddr.new('10.255.255.1/32').mask.should == 0xffffffff
  end
end

describe Net::IPv4IfAddr, :wildcard do
  it 'is a kind of Integer' do
    Net::IPv4IfAddr.new('0.0.0.1/0').wildcard.should be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').wildcard.should == 0xffffffff
    Net::IPv4IfAddr.new('10.255.255.1/8').wildcard.should == 0x00ffffff
    Net::IPv4IfAddr.new('10.255.255.1/31').wildcard.should == 0x00000001
    Net::IPv4IfAddr.new('10.255.255.1/32').wildcard.should == 0x00000000
  end
end

describe Net::IPv4IfAddr, :address do
  it 'is of type Net::IPv4Addr' do
    Net::IPv4IfAddr.new('0.0.0.1/0').address.should be_an_instance_of(Net::IPv4Addr)
  end

  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').address.should == Net::IPv4Addr.new('0.0.0.1')
    Net::IPv4IfAddr.new('1.0.0.1/8').address.should == Net::IPv4Addr.new('1.0.0.1')
    Net::IPv4IfAddr.new('10.0.0.1/8').address.should == Net::IPv4Addr.new('10.0.0.1')
    Net::IPv4IfAddr.new('172.15.0.1/12').address.should == Net::IPv4Addr.new('172.15.0.1')
    Net::IPv4IfAddr.new('172.16.0.1/12').address.should == Net::IPv4Addr.new('172.16.0.1')
    Net::IPv4IfAddr.new('192.167.0.1/16').address.should == Net::IPv4Addr.new('192.167.0.1')
    Net::IPv4IfAddr.new('192.168.0.1/16').address.should == Net::IPv4Addr.new('192.168.0.1')
    Net::IPv4IfAddr.new('192.168.32.1/24').address.should == Net::IPv4Addr.new('192.168.32.1')
    Net::IPv4IfAddr.new('192.168.32.0/31').address.should == Net::IPv4Addr.new('192.168.32.0')
    Net::IPv4IfAddr.new('192.168.32.1/31').address.should == Net::IPv4Addr.new('192.168.32.1')
    Net::IPv4IfAddr.new('192.168.32.1/32').address.should == Net::IPv4Addr.new('192.168.32.1')
    Net::IPv4IfAddr.new('192.169.32.1/32').address.should == Net::IPv4Addr.new('192.169.32.1')
  end
end

describe Net::IPv4IfAddr, :nic_id do
  it 'is kind of Integer' do
    Net::IPv4IfAddr.new('0.0.0.1/0').nic_id.should be_a_kind_of(Integer)
  end

  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').nic_id.should == 1
    Net::IPv4IfAddr.new('1.0.0.1/8').nic_id.should == 1
    Net::IPv4IfAddr.new('10.0.0.1/8').nic_id.should == 1
    Net::IPv4IfAddr.new('172.15.0.1/12').nic_id.should == 0x000f0001
    Net::IPv4IfAddr.new('172.16.0.1/12').nic_id.should == 1
    Net::IPv4IfAddr.new('192.167.0.1/16').nic_id.should == 1
    Net::IPv4IfAddr.new('192.168.0.1/16').nic_id.should == 1
    Net::IPv4IfAddr.new('192.168.32.1/24').nic_id.should == 1
    Net::IPv4IfAddr.new('192.168.32.0/31').nic_id.should == 0
    Net::IPv4IfAddr.new('192.168.32.1/31').nic_id.should == 1
    Net::IPv4IfAddr.new('192.168.32.1/32').nic_id.should == 0
    Net::IPv4IfAddr.new('192.169.32.1/32').nic_id.should == 0
  end
end

describe Net::IPv4IfAddr, :include? do
  it 'is correctly calculated' do
    Net::IPv4IfAddr.new('0.0.0.1/0').include?(Net::IPv4Addr.new('1.2.3.4')).should be_true
    Net::IPv4IfAddr.new('0.0.0.1/0').include?(Net::IPv4Addr.new('0.0.0.0')).should be_true
    Net::IPv4IfAddr.new('0.0.0.1/0').include?(Net::IPv4Addr.new('255.255.255.255')).should be_true
    Net::IPv4IfAddr.new('10.0.0.1/8').include?(Net::IPv4Addr.new('9.255.255.255')).should be_false
    Net::IPv4IfAddr.new('10.0.0.1/8').include?(Net::IPv4Addr.new('10.0.0.0')).should be_true
    Net::IPv4IfAddr.new('10.0.0.1/8').include?(Net::IPv4Addr.new('10.255.255.255')).should be_true
    Net::IPv4IfAddr.new('10.0.0.1/8').include?(Net::IPv4Addr.new('11.0.0.0')).should be_false
  end
end

describe Net::IPv4IfAddr, :== do
  it 'matches equal interface addresses' do
    (Net::IPv4IfAddr.new('0.0.0.1/0') == Net::IPv4IfAddr.new('0.0.0.1/0')).should be_true
    (Net::IPv4IfAddr.new('0.0.0.1/0') == Net::IPv4IfAddr.new('4.0.0.1/0')).should be_false
    (Net::IPv4IfAddr.new('10.0.0.1/8') == Net::IPv4IfAddr.new('10.0.0.1/8')).should be_true
    (Net::IPv4IfAddr.new('192.168.255.254/24') == Net::IPv4IfAddr.new('192.168.255.254/24')).should be_true
    (Net::IPv4IfAddr.new('192.168.255.255/32') == Net::IPv4IfAddr.new('192.168.255.255/32')).should be_true
  end
end

describe Net::IPv4IfAddr, :to_s do
  it 'produces correct output' do
    Net::IPv4IfAddr.new('0.0.0.1/0').to_s.should == '0.0.0.1/0'
    Net::IPv4IfAddr.new('10.0.0.1/8').to_s.should == '10.0.0.1/8'
    Net::IPv4IfAddr.new('192.168.255.254/24').to_s.should == '192.168.255.254/24'
    Net::IPv4IfAddr.new('192.168.255.255/32').to_s.should == '192.168.255.255/32'
  end
end

describe Net::IPv4IfAddr, :to_hash do
  it 'produces correct output' do
    Net::IPv4IfAddr.new('0.0.0.1/0').to_hash.should == { :addr => 0x00000001, :length => 0 }
    Net::IPv4IfAddr.new('10.0.0.1/8').to_hash.should == { :addr => 0x0a000001, :length => 8 }
    Net::IPv4IfAddr.new('192.168.255.254/24').to_hash.should == { :addr => 0xc0a8fffe, :length => 24 }
    Net::IPv4IfAddr.new('192.168.255.255/32').to_hash.should == { :addr => 0xc0a8ffff, :length => 32 }
  end
end
