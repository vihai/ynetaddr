
require File.expand_path('../../lib/netaddr', __FILE__)

describe Netaddr::IPv6Net, 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    Netaddr::IPv6Net.new('2a02:20:1:2::/64').prefix.should == 0x2a020020000100020000000000000000
    Netaddr::IPv6Net.new('2a02:20:1:2::/64').length.should == 64
  end

  it 'resets host bits' do
    Netaddr::IPv6Net.new('2a02:20:1:2:3:4:5:6/32').prefix.should == 0x2a020020000000000000000000000000
  end

  it 'reject invalid empty address' do
    lambda { Netaddr::IPv6Net.new('') }.should raise_error(ArgumentError)
  end

  it 'reject address without length' do
    lambda { Netaddr::IPv6Net.new('2a02:20::') }.should raise_error(ArgumentError)
  end

  it 'reject address with slash but without length' do
    lambda { Netaddr::IPv6Net.new('2a02:20::/') }.should raise_error(ArgumentError)
  end

  it 'reject address without prefix' do
    lambda { Netaddr::IPv6Net.new('/64') }.should raise_error(ArgumentError)
  end
end

describe Netaddr::IPv6Net, :mask_hex do
  it 'is correctly calculated' do
    Netaddr::IPv6Net.new('::/0').mask_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
    Netaddr::IPv6Net.new('2a00::/8').mask_hex.should == 'ff00:0000:0000:0000:0000:0000:0000:0000'
    Netaddr::IPv6Net.new('2a02:20::/32').mask_hex.should == 'ffff:ffff:0000:0000:0000:0000:0000:0000'
    Netaddr::IPv6Net.new('2a02:20::/127').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe'
    Netaddr::IPv6Net.new('2a02:20::/128').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
  end
end

describe Netaddr::IPv6Net, :wildcard_hex do
  it 'is correctly calculated' do
    Netaddr::IPv6Net.new('::/0').wildcard_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Netaddr::IPv6Net.new('2a00::/8').wildcard_hex.should == '00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Netaddr::IPv6Net.new('2a02:20::/32').wildcard_hex.should == '0000:0000:ffff:ffff:ffff:ffff:ffff:ffff'
    Netaddr::IPv6Net.new('2a02:20::/127').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0001'
    Netaddr::IPv6Net.new('2a02:20::/128').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
  end
end

describe Netaddr::IPv6Net, :prefix_hex do
  it 'is correctly calculated' do
    Netaddr::IPv6Net.new('::/0').prefix_hex.should == '::'
    Netaddr::IPv6Net.new('2a00::/8').prefix_hex.should == '2a00::'
    Netaddr::IPv6Net.new('2a02:20::/32').prefix_hex.should == '2a02:20::'
    Netaddr::IPv6Net.new('2a02:20::/127').prefix_hex.should == '2a02:20::'
    Netaddr::IPv6Net.new('2a02:20::/128').prefix_hex.should == '2a02:20::'
  end
end

describe Netaddr::IPv6Net, :unicast? do
  it 'is correctly calculated' do
#    Netaddr::IPv6Net.new('10.0.0.0/8').unicast?.should be_true
#    Netaddr::IPv6Net.new('172.16.0.0/12').unicast?.should be_true
#    Netaddr::IPv6Net.new('192.168.0.0/16').unicast?.should be_true
#    Netaddr::IPv6Net.new('224.0.0.0/32').unicast?.should be_false
#    Netaddr::IPv6Net.new('240.0.0.0/32').unicast?.should be_false
  end
end

describe Netaddr::IPv6Net, :multicast? do
  it 'is correctly calculated' do
#    Netaddr::IPv6Net.new('10.0.0.0/8').multicast?.should be_false
#    Netaddr::IPv6Net.new('172.16.0.0/12').multicast?.should be_false
#    Netaddr::IPv6Net.new('192.168.0.0/16').multicast?.should be_false
#    Netaddr::IPv6Net.new('224.0.0.0/32').multicast?.should be_true
#    Netaddr::IPv6Net.new('240.0.0.0/32').multicast?.should be_false
  end
end

describe Netaddr::IPv6Net, :new_pb_multicast do
  it 'produces correct address' do
# TODO
  end
end

describe Netaddr::IPv6Net, :reverse do
  it 'calculates the correct values' do
#    Netaddr::IPv6Net.new('0.0.0.0/0').reverse.should == '.in-addr.arpa'
#    Netaddr::IPv6Net.new('10.0.0.0/8').reverse.should == '10.in-addr.arpa'
#    Netaddr::IPv6Net.new('172.16.0.0/12').reverse.should == '172.in-addr.arpa'
#    Netaddr::IPv6Net.new('192.168.0.0/16').reverse.should == '168.192.in-addr.arpa'
#    Netaddr::IPv6Net.new('192.168.32.0/24').reverse.should == '32.168.192.in-addr.arpa'
#    Netaddr::IPv6Net.new('192.168.32.1/32').reverse.should == '1.32.168.192.in-addr.arpa'
  end
end


# parent class methods

describe Netaddr::IPv4Net, :prefix= do
# TODO
end

describe Netaddr::IPv6Net, :mask do
  it 'is correctly calculated' do
    Netaddr::IPv6Net.new('::/0').mask.should == 0x00000000000000000000000000000000
    Netaddr::IPv6Net.new('2a00::/8').mask.should == 0xff000000000000000000000000000000
    Netaddr::IPv6Net.new('2a02:20::/32').mask.should == 0xffffffff000000000000000000000000
    Netaddr::IPv6Net.new('2a02:20::/127').mask.should == 0xfffffffffffffffffffffffffffffffe
    Netaddr::IPv6Net.new('2a02:20::/128').mask.should == 0xffffffffffffffffffffffffffffffff
  end
end

describe Netaddr::IPv6Net, :wildcard do
  it 'is correctly calculated' do
    Netaddr::IPv6Net.new('::/0').wildcard.should == 0xffffffffffffffffffffffffffffffff
    Netaddr::IPv6Net.new('2a00::/8').wildcard.should == 0x00ffffffffffffffffffffffffffffff
    Netaddr::IPv6Net.new('2a02:20::/32').wildcard.should == 0x00000000ffffffffffffffffffffffff
    Netaddr::IPv6Net.new('2a02:20::/127').wildcard.should == 0x00000000000000000000000000000001
    Netaddr::IPv6Net.new('2a02:20::/128').wildcard.should == 0x00000000000000000000000000000000
  end
end

describe Netaddr::IPv6Net, :hosts do
  it 'produces a range' do
#    Netaddr::IPv6Net.new('10.0.0.0/8').hosts.should be_kind_of(Range)
  end

  it 'produces the correct range' do
#    Netaddr::IPv6Net.new('192.168.0.0/29').hosts.should be_eql(
#      Netaddr::IPv6Addr.new('192.168.0.1')..Netaddr::IPv6Addr.new('192.168.0.6'))
#    Netaddr::IPv6Net.new('192.168.0.0/30').hosts.should be_eql(
#      Netaddr::IPv6Addr.new('192.168.0.1')..Netaddr::IPv6Addr.new('192.168.0.2'))
#    Netaddr::IPv6Net.new('192.168.0.0/31').hosts.should be_eql(
#      Netaddr::IPv6Addr.new('192.168.0.0')..Netaddr::IPv6Addr.new('192.168.0.1'))
#    Netaddr::IPv6Net.new('192.168.0.0/32').hosts.should be_eql(
#      Netaddr::IPv6Addr.new('192.168.0.0')..Netaddr::IPv6Addr.new('192.168.0.0'))
  end
end

describe Netaddr::IPv6Net, :host_min do
  it 'calculates the correct values' do
#    Netaddr::IPv6Net.new('192.168.0.0/29').host_min.should == 0xc0a80001
#    Netaddr::IPv6Net.new('192.168.0.0/30').host_min.should == 0xc0a80001
#    Netaddr::IPv6Net.new('192.168.0.0/31').host_min.should == 0xc0a80000
#    Netaddr::IPv6Net.new('192.168.0.0/32').host_min.should == 0xc0a80000
  end
end

describe Netaddr::IPv6Net, :host_max do
  it 'calculates the correct values' do
#    Netaddr::IPv6Net.new('192.168.0.0/29').host_max.should == 0xc0a80006
#    Netaddr::IPv6Net.new('192.168.0.0/30').host_max.should == 0xc0a80002
#    Netaddr::IPv6Net.new('192.168.0.0/31').host_max.should == 0xc0a80001
#    Netaddr::IPv6Net.new('192.168.0.0/32').host_max.should == 0xc0a80000
  end
end

describe Netaddr::IPv4Net, :network do
# TODO
end

describe Netaddr::IPv6Net, :include? do
  it 'calculates the correct values' do
#    Netaddr::IPv6Net.new('0.0.0.0/0').include?(Netaddr::IPv6Addr.new('1.2.3.4')).should be_true
#    Netaddr::IPv6Net.new('0.0.0.0/0').include?(Netaddr::IPv6Addr.new('0.0.0.0')).should be_true
#    Netaddr::IPv6Net.new('0.0.0.0/0').include?(Netaddr::IPv6Addr.new('255.255.255.255')).should be_true
#    Netaddr::IPv6Net.new('10.0.0.0/8').include?(Netaddr::IPv6Addr.new('9.255.255.255')).should be_false
#    Netaddr::IPv6Net.new('10.0.0.0/8').include?(Netaddr::IPv6Addr.new('10.0.0.0')).should be_true
#    Netaddr::IPv6Net.new('10.0.0.0/8').include?(Netaddr::IPv6Addr.new('10.255.255.255')).should be_true
#    Netaddr::IPv6Net.new('10.0.0.0/8').include?(Netaddr::IPv6Addr.new('11.0.0.0')).should be_false
  end
end

describe Netaddr::IPv6Net, :to_s do
  it 'produces correct output' do
    Netaddr::IPv6Net.new('::/0').to_s.should == '::/0'
    Netaddr::IPv6Net.new('2a00::/8').to_s.should == '2a00::/8'
    Netaddr::IPv6Net.new('2aff::0/8').to_s.should == '2a00::/8'
    Netaddr::IPv6Net.new('2a02:20::/32').to_s.should == '2a02:20::/32'
    Netaddr::IPv6Net.new('2a02:20::/127').to_s.should == '2a02:20::/127'
    Netaddr::IPv6Net.new('2a02:20::/128').to_s.should == '2a02:20::/128'
  end
end

describe Netaddr::IPv6Net, 'to_hash' do
  it 'produces correct output' do
  end
end

describe Netaddr::IPv6Net, :== do
  it 'matches equal networks' do
##    (Netaddr::IPv4Net.new('0.0.0.0/0') == Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
##    (Netaddr::IPv4Net.new('0.0.0.0/0') == Netaddr::IPv4Net.new('4.0.0.0/0')).should be_true
##    (Netaddr::IPv4Net.new('10.0.0.0/8') == Netaddr::IPv4Net.new('10.0.0.0/8')).should be_true
##    (Netaddr::IPv4Net.new('192.168.255.255/24') == Netaddr::IPv4Net.new('192.168.255.255/24')).should be_true
##    (Netaddr::IPv4Net.new('192.168.255.255/32') == Netaddr::IPv4Net.new('192.168.255.255/32')).should be_true
  end

  it 'doesn\'t match different networks' do
#    (Netaddr::IPv4Net.new('10.0.0.0/8') == Netaddr::IPv4Net.new('13.0.0.0/8')).should be_false
#    (Netaddr::IPv4Net.new('192.168.255.255/24') == Netaddr::IPv4Net.new('192.168.255.255/32')).should be_false
#    (Netaddr::IPv4Net.new('192.168.255.255/32') == Netaddr::IPv4Net.new('192.168.255.255/24')).should be_false
  end
end

describe Netaddr::IPv4Net, :< do
  it 'compares correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.1.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('5.5.5.5/0')).should be_true
#    (Netaddr::IPv4Net.new('5.5.5.5/0') < Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/0') < Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.0.0/16')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.0.0/23')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.0.0/25')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('192.168.0.0/32')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') < Netaddr::IPv4Net.new('10.0.0.0/8')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') < Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/1') < Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/0') < Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('255.255.255.255/32') < Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
  end
end

describe Netaddr::IPv4Net, :<= do
  it 'compares correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.1.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('5.5.5.5/0')).should be_true
#    (Netaddr::IPv4Net.new('5.5.5.5/0') <= Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/0') <= Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.0.0/16')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.0.0/23')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.0.0/24')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.0.0/25')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('192.168.0.0/32')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') <= Netaddr::IPv4Net.new('10.0.0.0/8')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') <= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/1') <= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('0.0.0.0/0') <= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('255.255.255.255/32') <= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
  end
end

describe Netaddr::IPv4Net, :> do
  it 'compares correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.1.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('5.5.5.5/0')).should be_false
#    (Netaddr::IPv4Net.new('5.5.5.5/0') > Netaddr::IPv4Net.new('192.168.0.0/24')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.0.0/16')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.0.0/23')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.0.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.0.0/25')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('192.168.0.0/32')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') > Netaddr::IPv4Net.new('10.0.0.0/8')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') > Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') > Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/0') > Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('255.255.255.255/32') > Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
  end
end

describe Netaddr::IPv4Net, :>= do
  it 'compares correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.1.0/24')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('5.5.5.5/0')).should be_false
#    (Netaddr::IPv4Net.new('5.5.5.5/0') >= Netaddr::IPv4Net.new('192.168.0.0/24')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.0.0/16')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.0.0/23')).should be_false
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.0.0/24')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.0.0/25')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('192.168.0.0/32')).should be_true
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >= Netaddr::IPv4Net.new('10.0.0.0/8')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') >= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/1') >= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
#    (Netaddr::IPv4Net.new('0.0.0.0/0') >= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_true
#    (Netaddr::IPv4Net.new('255.255.255.255/32') >= Netaddr::IPv4Net.new('0.0.0.0/0')).should be_false
  end
end

describe Netaddr::IPv4Net, :>> do
  it 'operates correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >> 1).should == Netaddr::IPv4Net.new('192.168.0.0/25')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >> 2).should == Netaddr::IPv4Net.new('192.168.0.0/26')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >> 9).should == Netaddr::IPv4Net.new('192.168.0.0/32')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') >> -1).should == Netaddr::IPv4Net.new('192.168.0.0/23')
  end
end

describe Netaddr::IPv4Net, :<< do
  it 'operates correctly' do
#    (Netaddr::IPv4Net.new('192.168.0.0/24') << 1).should == Netaddr::IPv4Net.new('192.168.0.0/23')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') << 2).should == Netaddr::IPv4Net.new('192.168.0.0/22')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') << 25).should == Netaddr::IPv4Net.new('0.0.0.0/0')
#    (Netaddr::IPv4Net.new('192.168.0.0/24') << -1).should == Netaddr::IPv4Net.new('192.168.0.0/25')
  end
end

describe Netaddr::IPv4Net, :=== do
# TODO
end
