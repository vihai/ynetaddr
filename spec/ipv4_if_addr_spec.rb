
require File.expand_path('../../lib/netaddr', __FILE__)

describe Netaddr::IPv4IfAddr, 'constructor' do
  it 'accepts d.d.d.d/l format' do
    Netaddr::IPv4IfAddr.new('192.168.0.1/24').addr.should == 0xC0A80001
    Netaddr::IPv4IfAddr.new('192.168.0.1/24').length.should == 24
  end

  it 'rejects network address' do
    lambda { Netaddr::IPv4IfAddr.new('10.0.0.0/8') }.should raise_error(Netaddr::IPv4IfAddr::InvalidAddress)
  end

  it 'rejects broadcast address' do
    lambda { Netaddr::IPv4IfAddr.new('10.255.255.255/8') }.should raise_error(Netaddr::IPv4IfAddr::InvalidAddress)
  end

  it 'reject invalid empty address' do
    lambda { Netaddr::IPv4IfAddr.new('') }.should raise_error(Netaddr::IPv4IfAddr::InvalidFormat)
  end

  it 'reject addr without length' do
    lambda { Netaddr::IPv4IfAddr.new('10.0.255.0') }.should raise_error(Netaddr::IPv4IfAddr::InvalidFormat)
  end

  it 'reject addr with slash but without length' do
    lambda { Netaddr::IPv4IfAddr.new('10.0.255.0/') }.should raise_error(Netaddr::IPv4IfAddr::InvalidFormat)
  end

  it 'reject addr without addr' do
    lambda { Netaddr::IPv4IfAddr.new('/24') }.should raise_error(Netaddr::IPv4IfAddr::InvalidFormat)
  end
end

describe Netaddr::IPv4IfAddr, 'mask' do
  it 'is correctly calculated' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').mask.should == 0x00000000
    Netaddr::IPv4IfAddr.new('10.255.255.1/8').mask.should == 0xff000000
    Netaddr::IPv4IfAddr.new('10.255.255.1/31').mask.should == 0xfffffffe
    Netaddr::IPv4IfAddr.new('10.255.255.1/32').mask.should == 0xffffffff
  end
end

describe Netaddr::IPv4IfAddr, 'mask_dotquad' do
  it 'is correctly calculated' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').mask_dotquad.should == '0.0.0.0'
    Netaddr::IPv4IfAddr.new('10.255.255.1/8').mask_dotquad.should == '255.0.0.0'
    Netaddr::IPv4IfAddr.new('10.255.255.1/31').mask_dotquad.should == '255.255.255.254'
    Netaddr::IPv4IfAddr.new('10.255.255.1/32').mask_dotquad.should == '255.255.255.255'
  end
end

describe Netaddr::IPv4IfAddr, 'wildcard' do
  it 'is correctly calculated' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').wildcard.should == 0xffffffff
    Netaddr::IPv4IfAddr.new('10.255.255.1/8').wildcard.should == 0x00ffffff
    Netaddr::IPv4IfAddr.new('10.255.255.1/31').wildcard.should == 0x00000001
    Netaddr::IPv4IfAddr.new('10.255.255.1/32').wildcard.should == 0x00000000
  end
end

describe Netaddr::IPv4IfAddr, 'ipclass' do
  it 'is correctly calculated' do
    Netaddr::IPv4IfAddr.new('10.0.0.1/8').ipclass.should == :a
    Netaddr::IPv4IfAddr.new('172.16.0.1/12').ipclass.should == :b
    Netaddr::IPv4IfAddr.new('192.168.0.1/16').ipclass.should == :c
    Netaddr::IPv4IfAddr.new('224.0.0.1/32').ipclass.should == :d
    Netaddr::IPv4IfAddr.new('240.0.0.1/32').ipclass.should == :e
  end
end

describe Netaddr::IPv4IfAddr, 'is_rfc1918?' do
  it 'calculates the correct values' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').is_rfc1918?.should be_false
    Netaddr::IPv4IfAddr.new('1.0.0.1/8').is_rfc1918?.should be_false
    Netaddr::IPv4IfAddr.new('10.0.0.1/8').is_rfc1918?.should be_true
    Netaddr::IPv4IfAddr.new('172.15.0.1/12').is_rfc1918?.should be_false
    Netaddr::IPv4IfAddr.new('172.16.0.1/12').is_rfc1918?.should be_true
    Netaddr::IPv4IfAddr.new('192.167.0.1/16').is_rfc1918?.should be_false
    Netaddr::IPv4IfAddr.new('192.168.0.1/16').is_rfc1918?.should be_true
    Netaddr::IPv4IfAddr.new('192.168.32.1/24').is_rfc1918?.should be_true
    Netaddr::IPv4IfAddr.new('192.168.32.1/32').is_rfc1918?.should be_true
    Netaddr::IPv4IfAddr.new('192.169.32.1/32').is_rfc1918?.should be_false
  end
end

describe Netaddr::IPv4IfAddr, 'to_s' do
  it 'produces correct output' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').to_s.should == '0.0.0.1/0'
    Netaddr::IPv4IfAddr.new('10.0.0.1/8').to_s.should == '10.0.0.1/8'
    Netaddr::IPv4IfAddr.new('192.168.255.254/24').to_s.should == '192.168.255.254/24'
    Netaddr::IPv4IfAddr.new('192.168.255.255/32').to_s.should == '192.168.255.255/32'
  end
end

describe Netaddr::IPv4IfAddr, 'to_hash' do
  it 'produces correct output' do
    Netaddr::IPv4IfAddr.new('0.0.0.1/0').to_hash.should == { :addr => 0x00000001, :length => 0 }
    Netaddr::IPv4IfAddr.new('10.0.0.1/8').to_hash.should == { :addr => 0x0a000001, :length => 8 }
    Netaddr::IPv4IfAddr.new('192.168.255.254/24').to_hash.should == { :addr => 0xc0a8fffe, :length => 24 }
    Netaddr::IPv4IfAddr.new('192.168.255.255/32').to_hash.should == { :addr => 0xc0a8ffff, :length => 32 }
  end
end
