
require 'ynetaddr'

module Net

describe IPv4Net, 'constructor' do
  it 'accepts d.d.d.d/l format' do
    IPv4Net.new('192.168.0.0/24').prefix.should == 0xC0A80000
    IPv4Net.new('192.168.0.0/24').length.should == 24
  end

  it 'resets host bits' do
    IPv4Net.new('10.0.255.0/16').prefix.should == 0x0A000000
  end

  it 'reject invalid empty address' do
    lambda { IPv4Net.new('') }.should raise_error(ArgumentError)
  end

  it 'reject prefix without length' do
    lambda { IPv4Net.new('10.0.255.0') }.should raise_error(ArgumentError)
  end

  it 'reject prefix with slash but without length' do
    lambda { IPv4Net.new('10.0.255.0/') }.should raise_error(ArgumentError)
  end

  it 'reject prefix without prefix' do
    lambda { IPv4Net.new('/24') }.should raise_error(ArgumentError)
  end
end

describe IPv4Net, :mask_dotquad do
  it 'is correctly calculated' do
    IPv4Net.new('0.0.0.0/0').mask_dotquad.should == '0.0.0.0'
    IPv4Net.new('10.255.255.0/8').mask_dotquad.should == '255.0.0.0'
    IPv4Net.new('10.255.255.0/31').mask_dotquad.should == '255.255.255.254'
    IPv4Net.new('10.255.255.0/32').mask_dotquad.should == '255.255.255.255'
  end
end

describe IPv4Net, :wildcard_dotquad do
  it 'is correctly calculated' do
    IPv4Net.new('0.0.0.0/0').wildcard_dotquad.should == '255.255.255.255'
    IPv4Net.new('10.255.255.0/8').wildcard_dotquad.should == '0.255.255.255'
    IPv4Net.new('10.255.255.0/31').wildcard_dotquad.should == '0.0.0.1'
    IPv4Net.new('10.255.255.0/32').wildcard_dotquad.should == '0.0.0.0'
  end
end

describe IPv4Net, :prefix_dotquad do
  it 'calculates the correct value' do
    IPv4Net.new('192.168.0.0/29').prefix_dotquad.should == '192.168.0.0'
    IPv4Net.new('192.168.0.0/30').prefix_dotquad.should == '192.168.0.0'
    IPv4Net.new('192.168.0.0/31').prefix_dotquad.should == '192.168.0.0'
    IPv4Net.new('192.168.0.0/32').prefix_dotquad.should == '192.168.0.0'
  end
end

describe IPv4Net, :ipclass do
  it 'is correctly calculated' do
    IPv4Net.new('10.0.0.0/8').ipclass.should == :a
    IPv4Net.new('172.16.0.0/12').ipclass.should == :b
    IPv4Net.new('192.168.0.0/16').ipclass.should == :c
    IPv4Net.new('224.0.0.0/32').ipclass.should == :d
    IPv4Net.new('240.0.0.0/32').ipclass.should == :e
  end

  it 'should raise an error for network spanning more than one class' do
    lambda { IPv4Net.new('0.0.0.0/0').ipaddr }.should raise_error
  end
end

describe IPv4Net, :unicast? do
  it 'is correctly calculated' do
    IPv4Net.new('10.0.0.0/8').unicast?.should be_true
    IPv4Net.new('172.16.0.0/12').unicast?.should be_true
    IPv4Net.new('192.168.0.0/16').unicast?.should be_true
    IPv4Net.new('224.0.0.0/32').unicast?.should be_false
    IPv4Net.new('240.0.0.0/32').unicast?.should be_false
  end
end

describe IPv4Net, :multicast? do
  it 'is correctly calculated' do
    IPv4Net.new('10.0.0.0/8').multicast?.should be_false
    IPv4Net.new('172.16.0.0/12').multicast?.should be_false
    IPv4Net.new('192.168.0.0/16').multicast?.should be_false
    IPv4Net.new('224.0.0.0/32').multicast?.should be_true
    IPv4Net.new('240.0.0.0/32').multicast?.should be_false
  end
end

describe IPv4Net, :broadcast do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').broadcast.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct value' do
    IPv4Net.new('192.168.0.0/29').broadcast.should == 0xc0a80007
    IPv4Net.new('192.168.0.0/30').broadcast.should == 0xc0a80003
    IPv4Net.new('192.168.0.0/31').broadcast.should be_nil
    IPv4Net.new('192.168.0.0/32').broadcast.should be_nil
  end
end

describe IPv4Net, :reverse do
  it 'calculates the correct values' do
    IPv4Net.new('0.0.0.0/0').reverse.should == '.in-addr.arpa'
    IPv4Net.new('10.0.0.0/8').reverse.should == '10.in-addr.arpa'
    IPv4Net.new('172.16.0.0/12').reverse.should == '172.in-addr.arpa'
    IPv4Net.new('192.168.0.0/16').reverse.should == '168.192.in-addr.arpa'
    IPv4Net.new('192.168.32.0/24').reverse.should == '32.168.192.in-addr.arpa'
    IPv4Net.new('192.168.32.1/32').reverse.should == '1.32.168.192.in-addr.arpa'
  end
end

describe IPv4Net, 'is_rfc1918?' do
  it 'calculates the correct values' do
    IPv4Net.new('0.0.0.0/0').is_rfc1918?.should be_false
    IPv4Net.new('1.0.0.0/8').is_rfc1918?.should be_false
    IPv4Net.new('10.0.0.0/8').is_rfc1918?.should be_true
    IPv4Net.new('172.15.0.0/12').is_rfc1918?.should be_false
    IPv4Net.new('172.16.0.0/12').is_rfc1918?.should be_true
    IPv4Net.new('192.167.0.0/16').is_rfc1918?.should be_false
    IPv4Net.new('192.168.0.0/16').is_rfc1918?.should be_true
    IPv4Net.new('192.168.32.0/24').is_rfc1918?.should be_true
    IPv4Net.new('192.168.32.1/32').is_rfc1918?.should be_true
    IPv4Net.new('192.169.32.1/32').is_rfc1918?.should be_false
  end
end

# parent class methods

describe IPv4Net, :prefix= do
  it 'returns prefix' do
    (IPv4Net.new('192.168.0.0/16').prefix = '192.167.0.0').should == '192.167.0.0'
  end

  it 'assigns prefix host bits' do
    a = IPv4Net.new('192.168.0.0/16')
    a.prefix = '192.167.0.0'
    a.should == IPv4Net.new('192.167.0.0/16')
  end

  it 'resets host bits' do
    a = IPv4Net.new('192.168.0.0/16')
    a.prefix = '192.167.0.255'
    a.should == IPv4Net.new('192.167.0.0/16')
  end
end

describe IPv4Net, :length= do
  it 'returns length' do
    (IPv4Net.new('192.168.0.0/24').length = 16).should == 16
  end

  it 'rejects invalid length' do
    lambda { IPv4Net.new('192.168.0.0/24').length = -1 }.should raise_error
    lambda { IPv4Net.new('192.168.0.0/24').length = 33 }.should raise_error
  end

  it 'resets host bits' do
    a = IPv4Net.new('192.168.22.0/24')
    a.length = 16
    a.should == IPv4Net.new('192.168.0.0/16')
  end
end

describe IPv4Net, :mask do
  it 'is kind of Integer' do
    IPv4Net.new('0.0.0.0/0').mask.should be_an_kind_of(Integer)
  end

  it 'is correctly calculated' do
    IPv4Net.new('0.0.0.0/0').mask.should == 0x00000000
    IPv4Net.new('10.255.255.0/8').mask.should == 0xff000000
    IPv4Net.new('10.255.255.0/31').mask.should == 0xfffffffe
    IPv4Net.new('10.255.255.0/32').mask.should == 0xffffffff
  end
end

describe IPv4Net, :wildcard do
  it 'is kind of Integer' do
    IPv4Net.new('0.0.0.0/0').wildcard.should be_an_kind_of(Integer)
  end

  it 'is correctly calculated' do
    IPv4Net.new('0.0.0.0/0').wildcard.should == 0xffffffff
    IPv4Net.new('10.255.255.0/8').wildcard.should == 0x00ffffff
    IPv4Net.new('10.255.255.0/31').wildcard.should == 0x00000001
    IPv4Net.new('10.255.255.0/32').wildcard.should == 0x00000000
  end
end

describe IPv4Net, :addresses do
  it 'produces a range' do
    IPv4Net.new('10.0.0.0/8').addresses.should be_kind_of(Range)
  end

  it 'produces the correct range' do
    IPv4Net.new('192.168.0.0/29').addresses.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.7'))
    IPv4Net.new('192.168.0.0/30').addresses.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.3'))
    IPv4Net.new('192.168.0.0/31').addresses.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.1'))
    IPv4Net.new('192.168.0.0/32').addresses.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.0'))
  end
end

describe IPv4Net, :first_ip do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').first_ip.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    IPv4Net.new('192.168.0.0/29').first_ip.should == 0xc0a80000
    IPv4Net.new('192.168.0.0/30').first_ip.should == 0xc0a80000
    IPv4Net.new('192.168.0.0/31').first_ip.should == 0xc0a80000
    IPv4Net.new('192.168.0.0/32').first_ip.should == 0xc0a80000
  end
end

describe IPv4Net, :last_ip do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').first_ip.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    IPv4Net.new('192.168.0.0/29').last_ip.should == 0xc0a80007
    IPv4Net.new('192.168.0.0/30').last_ip.should == 0xc0a80003
    IPv4Net.new('192.168.0.0/31').last_ip.should == 0xc0a80001
    IPv4Net.new('192.168.0.0/32').last_ip.should == 0xc0a80000
  end
end

describe IPv4Net, :hosts do
  it 'produces a range' do
    IPv4Net.new('10.0.0.0/8').hosts.should be_kind_of(Range)
  end

  it 'produces the correct range' do
    IPv4Net.new('192.168.0.0/29').hosts.should be_eql(
      IPv4Addr.new('192.168.0.1')..IPv4Addr.new('192.168.0.6'))
    IPv4Net.new('192.168.0.0/30').hosts.should be_eql(
      IPv4Addr.new('192.168.0.1')..IPv4Addr.new('192.168.0.2'))
    IPv4Net.new('192.168.0.0/31').hosts.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.1'))
    IPv4Net.new('192.168.0.0/32').hosts.should be_eql(
      IPv4Addr.new('192.168.0.0')..IPv4Addr.new('192.168.0.0'))
  end
end

describe IPv4Net, :first_host do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').first_host.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    IPv4Net.new('192.168.0.0/29').first_host.should == 0xc0a80001
    IPv4Net.new('192.168.0.0/30').first_host.should == 0xc0a80001
    IPv4Net.new('192.168.0.0/31').first_host.should == 0xc0a80000
    IPv4Net.new('192.168.0.0/32').first_host.should == 0xc0a80000
  end
end

describe IPv4Net, :last_host do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').first_host.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    IPv4Net.new('192.168.0.0/29').last_host.should == 0xc0a80006
    IPv4Net.new('192.168.0.0/30').last_host.should == 0xc0a80002
    IPv4Net.new('192.168.0.0/31').last_host.should == 0xc0a80001
    IPv4Net.new('192.168.0.0/32').last_host.should == 0xc0a80000
  end
end

describe IPv4Net, :network do
  it 'is of type IPv4Addr' do
    IPv4Net.new('0.0.0.0/0').network.should be_an_instance_of(IPv4Addr)
  end

  it 'calculates the correct values' do
    IPv4Net.new('192.168.0.255/24').network.should == IPv4Addr.new('192.168.0.0')
    IPv4Net.new('192.168.0.0/29').network.should == IPv4Addr.new('192.168.0.0')
    IPv4Net.new('192.168.0.0/30').network.should == IPv4Addr.new('192.168.0.0')
    IPv4Net.new('192.168.0.0/31').network.should == nil
    IPv4Net.new('192.168.0.0/32').network.should == nil
  end
end

describe IPv4Net, :include? do
  it 'calculates the correct values' do
    IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('1.2.3.4')).should be_true
    IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('0.0.0.0')).should be_true
    IPv4Net.new('0.0.0.0/0').include?(IPv4Addr.new('255.255.255.255')).should be_true
    IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('9.255.255.255')).should be_false
    IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('10.0.0.0')).should be_true
    IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('10.255.255.255')).should be_true
    IPv4Net.new('10.0.0.0/8').include?(IPv4Addr.new('11.0.0.0')).should be_false
  end
end

describe IPv4Net, :to_s do
  it 'produces correct output' do
    IPv4Net.new('0.0.0.0/0').to_s.should == '0.0.0.0/0'
    IPv4Net.new('10.0.0.0/8').to_s.should == '10.0.0.0/8'
    IPv4Net.new('192.168.255.255/24').to_s.should == '192.168.255.0/24'
    IPv4Net.new('192.168.255.255/32').to_s.should == '192.168.255.255/32'
  end
end

describe IPv4Net, :to_hash do
  it 'produces correct output' do
    IPv4Net.new('0.0.0.0/0').to_hash.should == { :prefix => 0x00000000, :length => 0 }
    IPv4Net.new('10.0.0.0/8').to_hash.should == { :prefix => 0x0a000000, :length => 8 }
    IPv4Net.new('192.168.255.255/24').to_hash.should == { :prefix => 0xc0a8ff00, :length => 24 }
    IPv4Net.new('192.168.255.255/32').to_hash.should == { :prefix => 0xc0a8ffff, :length => 32 }
  end
end

describe IPv4Net, :== do
  it 'matches equal networks' do
    (IPv4Net.new('0.0.0.0/0') == IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/0') == IPv4Net.new('4.0.0.0/0')).should be_true
    (IPv4Net.new('10.0.0.0/8') == IPv4Net.new('10.0.0.0/8')).should be_true
    (IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.0/24')).should be_true
    (IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.255/24')).should be_true
    (IPv4Net.new('192.168.255.255/32') == IPv4Net.new('192.168.255.255/32')).should be_true
  end

  it 'doesn\'t match different networks' do
    (IPv4Net.new('10.0.0.0/8') == IPv4Net.new('13.0.0.0/8')).should be_false
    (IPv4Net.new('192.168.255.255/24') == IPv4Net.new('192.168.255.255/32')).should be_false
    (IPv4Net.new('192.168.255.255/32') == IPv4Net.new('192.168.255.255/24')).should be_false
  end
end

describe IPv4Net, :< do
  it 'compares correctly' do
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.1.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('5.5.5.5/0')).should be_true
    (IPv4Net.new('5.5.5.5/0') < IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/0') < IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/16')).should be_true
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/23')).should be_true
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/25')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('192.168.0.0/32')).should be_false
    (IPv4Net.new('192.168.0.0/24') < IPv4Net.new('10.0.0.0/8')).should be_false
    (IPv4Net.new('0.0.0.0/1') < IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/1') < IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/0') < IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('255.255.255.255/32') < IPv4Net.new('0.0.0.0/0')).should be_true
  end
end

describe IPv4Net, :<= do
  it 'compares correctly' do
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.1.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('5.5.5.5/0')).should be_true
    (IPv4Net.new('5.5.5.5/0') <= IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/0') <= IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/16')).should be_true
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/23')).should be_true
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/24')).should be_true
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/25')).should be_false
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('192.168.0.0/32')).should be_false
    (IPv4Net.new('192.168.0.0/24') <= IPv4Net.new('10.0.0.0/8')).should be_false
    (IPv4Net.new('0.0.0.0/1') <= IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/1') <= IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('0.0.0.0/0') <= IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('255.255.255.255/32') <= IPv4Net.new('0.0.0.0/0')).should be_true
  end
end

describe IPv4Net, :> do
  it 'compares correctly' do
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.1.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('5.5.5.5/0')).should be_false
    (IPv4Net.new('5.5.5.5/0') > IPv4Net.new('192.168.0.0/24')).should be_true
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/16')).should be_false
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/23')).should be_false
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/25')).should be_true
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('192.168.0.0/32')).should be_true
    (IPv4Net.new('192.168.0.0/24') > IPv4Net.new('10.0.0.0/8')).should be_false
    (IPv4Net.new('0.0.0.0/1') > IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('0.0.0.0/1') > IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('0.0.0.0/0') > IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('255.255.255.255/32') > IPv4Net.new('0.0.0.0/0')).should be_false
  end
end

describe IPv4Net, :>= do
  it 'compares correctly' do
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.1.0/24')).should be_false
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('5.5.5.5/0')).should be_false
    (IPv4Net.new('5.5.5.5/0') >= IPv4Net.new('192.168.0.0/24')).should be_true
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/16')).should be_false
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/23')).should be_false
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/24')).should be_true
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/25')).should be_true
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('192.168.0.0/32')).should be_true
    (IPv4Net.new('192.168.0.0/24') >= IPv4Net.new('10.0.0.0/8')).should be_false
    (IPv4Net.new('0.0.0.0/1') >= IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('0.0.0.0/1') >= IPv4Net.new('0.0.0.0/0')).should be_false
    (IPv4Net.new('0.0.0.0/0') >= IPv4Net.new('0.0.0.0/0')).should be_true
    (IPv4Net.new('255.255.255.255/32') >= IPv4Net.new('0.0.0.0/0')).should be_false
  end
end

describe IPv4Net, :overlaps? do
  it 'is false for smaller non-overlapping networks' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('10.1.1.1/24')).should be_false
  end

  it 'is false for bigger non-overlapping networks' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('10.0.0.0/8')).should be_false
  end

  it 'is false for equal-size non-overlapping networks' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('192.169.0.0/16')).should be_false
  end

  it 'is true for same network' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('192.168.0.0/16')).should be_true
  end

  it 'is true for bigger network containing us' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('192.0.0.0/8')).should be_true
  end

  it 'is true for smaller network contained' do
    (IPv4Net.new('192.168.0.0/16').overlaps?('192.168.16.0/24')).should be_true
  end
end

describe IPv4Net, :>> do
  it 'operates correctly' do
    (IPv4Net.new('192.168.0.0/24') >> 1).should == IPv4Net.new('192.168.0.0/25')
    (IPv4Net.new('192.168.0.0/24') >> 2).should == IPv4Net.new('192.168.0.0/26')
    (IPv4Net.new('192.168.0.0/24') >> 9).should == IPv4Net.new('192.168.0.0/32')
    (IPv4Net.new('192.168.0.0/24') >> -1).should == IPv4Net.new('192.168.0.0/23')
  end
end

describe IPv4Net, :<< do
  it 'operates correctly' do
    (IPv4Net.new('192.168.0.0/24') << 1).should == IPv4Net.new('192.168.0.0/23')
    (IPv4Net.new('192.168.0.0/24') << 2).should == IPv4Net.new('192.168.0.0/22')
    (IPv4Net.new('192.168.0.0/24') << 25).should == IPv4Net.new('0.0.0.0/0')
    (IPv4Net.new('192.168.0.0/24') << -1).should == IPv4Net.new('192.168.0.0/25')
  end
end

describe IPv4Net, :=== do
  it 'returns true if other is an IPv4 address and is contained in this network' do
    (IPv4Net.new('192.168.0.0/24') === IPv4Addr.new('192.168.0.254')).should be_true
  end

  it 'returns false if other is not contained in this network' do
    (IPv4Net.new('192.168.0.0/24') === IPv4Addr.new('192.168.1.254')).should be_false
  end

  it 'returns false if other is not IPv4 address' do
    (IPv4Net.new('192.168.0.0/24') === 1234).should be_false
  end
end

describe IPv4Net, :<=> do
  it 'returns 0 if networks are equal' do
    (IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/24')).should == 0
  end

  it 'returns -1 if networks have the same prefix length and prefix a < prefix b' do
    (IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.169.0.0/24')).should == -1
  end

  it 'returns +1 if networks have the same prefix length and prefix a < prefix b' do
    (IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.167.0.0/24')).should == 1
  end

  it 'returns -1 if network a is smaller than network b' do
    (IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/23')).should == -1
  end

  it 'returns +1 if network a is bigger than network b' do
    (IPv4Net.new('192.168.0.0/24') <=> IPv4Net.new('192.168.0.0/25')).should == 1
  end
end

end
