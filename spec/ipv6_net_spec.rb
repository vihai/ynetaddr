
require 'ynetaddr'

describe Net::IPv6Net, 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    Net::IPv6Net.new('2a02:20:1:2::/64').prefix.should == 0x2a020020000100020000000000000000
    Net::IPv6Net.new('2a02:20:1:2::/64').length.should == 64
  end

  it 'resets host bits' do
    Net::IPv6Net.new('2a02:20:1:2:3:4:5:6/32').prefix.should == 0x2a020020000000000000000000000000
  end

  it 'reject invalid empty address' do
    lambda { Net::IPv6Net.new('') }.should raise_error(ArgumentError)
  end

  it 'reject address without length' do
    lambda { Net::IPv6Net.new('2a02:20::') }.should raise_error(ArgumentError)
  end

  it 'reject address with slash but without length' do
    lambda { Net::IPv6Net.new('2a02:20::/') }.should raise_error(ArgumentError)
  end

  it 'reject address without prefix' do
    lambda { Net::IPv6Net.new('/64') }.should raise_error(ArgumentError)
  end
end

describe Net::IPv6Net, :mask_hex do
  it 'is correctly calculated' do
    Net::IPv6Net.new('::/0').mask_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
    Net::IPv6Net.new('2a00::/8').mask_hex.should == 'ff00:0000:0000:0000:0000:0000:0000:0000'
    Net::IPv6Net.new('2a02:20::/32').mask_hex.should == 'ffff:ffff:0000:0000:0000:0000:0000:0000'
    Net::IPv6Net.new('2a02:20::/127').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe'
    Net::IPv6Net.new('2a02:20::/128').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
  end
end

describe Net::IPv6Net, :wildcard_hex do
  it 'is correctly calculated' do
    Net::IPv6Net.new('::/0').wildcard_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6Net.new('2a00::/8').wildcard_hex.should == '00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6Net.new('2a02:20::/32').wildcard_hex.should == '0000:0000:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6Net.new('2a02:20::/127').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0001'
    Net::IPv6Net.new('2a02:20::/128').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
  end
end

describe Net::IPv6Net, :prefix_hex do
  it 'is correctly calculated' do
    Net::IPv6Net.new('::/0').prefix_hex.should == '::'
    Net::IPv6Net.new('2a00::/8').prefix_hex.should == '2a00::'
    Net::IPv6Net.new('2a02:20::/32').prefix_hex.should == '2a02:20::'
    Net::IPv6Net.new('2a02:20::/127').prefix_hex.should == '2a02:20::'
    Net::IPv6Net.new('2a02:20::/128').prefix_hex.should == '2a02:20::'
  end
end

describe Net::IPv6Net, :unicast? do
  it 'return false for multicast range' do
    Net::IPv6Net.new('f000::/4').unicast?.should be_false
    Net::IPv6Net.new('ff00::/8').unicast?.should be_false
    Net::IPv6Net.new('ff70::/9').unicast?.should be_false
    Net::IPv6Net.new('ffff::/16').unicast?.should be_false
  end

  it 'returns true for unicast range' do
    Net::IPv6Net.new('2a02:20::/32').unicast?.should be_true
  end
end

describe Net::IPv6Net, :multicast? do
  it 'returns true if network wholly multicast' do
    Net::IPv6Net.new('ff00::/8').multicast?.should be_true
    Net::IPv6Net.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/32').multicast?.should be_true
    Net::IPv6Net.new('ff7f:1:2:3::/96').multicast?.should be_true
  end

  it 'returns false if network wholly not multicast' do
    Net::IPv6Net.new('2a02::/32').multicast?.should be_false
    Net::IPv6Net.new('::/8').multicast?.should be_false
  end

  it 'returns false if network partially multicast' do
    Net::IPv6Net.new('f::/4').multicast?.should be_false
  end
end

describe Net::IPv6Net, :new_pb_multicast do
  it 'produces correct address' do
    Net::IPv6Net.new('2a02:20:1:2::5/64').new_pb_multicast(:global, 0x1234).should == 'ff3e:40:2a02:20:1:2:0:1234'
  end
end

describe Net::IPv6Net, :reverse do
  it 'calculates the correct values' do
    Net::IPv6Net.new('::/0').reverse.should == '.ip6.arpa'
    Net::IPv6Net.new('2a02:20:1:2::/64').reverse.should == '2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa'
    Net::IPv6Net.new('2a02:20:1:2::5/128').reverse.should ==
      '5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.1.0.0.0.0.2.0.0.2.0.a.2.ip6.arpa'
  end
end


# parent class methods

describe Net::IPv6Net, :prefix= do
  it 'returns prefix' do
    (Net::IPv6Net.new('2a02:20::/32').prefix = '2a02:30::').should == '2a02:30::'
  end

  it 'assigns prefix host bits' do
    a = Net::IPv6Net.new('2a02:20::/32')
    a.prefix = '2a02:30::'
    a.should == Net::IPv6Net.new('2a02:30::/32')
  end

  it 'resets host bits' do
    a = Net::IPv6Net.new('2a02:20::/32')
    a.prefix = '2a02:30::44'
    a.should == Net::IPv6Net.new('2a02:30::/32')
  end
end

describe Net::IPv6Net, :length= do
  it 'returns length' do
    (Net::IPv6Net.new('2a02:20::/32').length = 16).should == 16
  end

  it 'rejects invalid length' do
    lambda { Net::IPv6Net.new('2a02:20::/32').length = -1 }.should raise_error
    lambda { Net::IPv6Net.new('2a02:20::/32').length = 129 }.should raise_error
  end

  it 'resets host bits' do
    a = Net::IPv6Net.new('2a02:20::/32')
    a.length = 16
    a.should == Net::IPv6Net.new('2a02::/16')
  end
end

describe Net::IPv6Net, :mask do
  it 'is correctly calculated' do
    Net::IPv6Net.new('::/0').mask.should == 0x00000000000000000000000000000000
    Net::IPv6Net.new('2a00::/8').mask.should == 0xff000000000000000000000000000000
    Net::IPv6Net.new('2a02:20::/32').mask.should == 0xffffffff000000000000000000000000
    Net::IPv6Net.new('2a02:20::/127').mask.should == 0xfffffffffffffffffffffffffffffffe
    Net::IPv6Net.new('2a02:20::/128').mask.should == 0xffffffffffffffffffffffffffffffff
  end
end

describe Net::IPv6Net, :wildcard do
  it 'is correctly calculated' do
    Net::IPv6Net.new('::/0').wildcard.should == 0xffffffffffffffffffffffffffffffff
    Net::IPv6Net.new('2a00::/8').wildcard.should == 0x00ffffffffffffffffffffffffffffff
    Net::IPv6Net.new('2a02:20::/32').wildcard.should == 0x00000000ffffffffffffffffffffffff
    Net::IPv6Net.new('2a02:20::/127').wildcard.should == 0x00000000000000000000000000000001
    Net::IPv6Net.new('2a02:20::/128').wildcard.should == 0x00000000000000000000000000000000
  end
end

describe Net::IPv6Net, :hosts do
  it 'produces a range' do
    Net::IPv6Net.new('2a02:20:1:2::/64').hosts.should be_kind_of(Range)
  end

  it 'produces the correct range' do
    Net::IPv6Net.new('2a02:20:1:2::/64').hosts.should be_eql(
      Net::IPv6Addr.new('2a02:20:1:2::0')..
      Net::IPv6Addr.new('2a02:20:1:2:ffff:ffff:ffff:ffff'))
    Net::IPv6Net.new('2a02:20:1:2::1/127').hosts.should be_eql(
      Net::IPv6Addr.new('2a02:20:1:2::0')..
      Net::IPv6Addr.new('2a02:20:1:2::1'))
    Net::IPv6Net.new('2a02:20:1:2::1/128').hosts.should be_eql(
      Net::IPv6Addr.new('2a02:20:1:2::1')..
      Net::IPv6Addr.new('2a02:20:1:2::1'))
  end
end

describe Net::IPv6Net, :host_min do
  it 'calculates the correct values' do
    Net::IPv6Net.new('2a02:20:1:2::/64').host_min.should == 0x2a020020000100020000000000000000
    Net::IPv6Net.new('2a02:20:1:2::0/127').host_min.should == 0x2a020020000100020000000000000000
    Net::IPv6Net.new('2a02:20:1:2::1/128').host_min.should == 0x2a020020000100020000000000000001
  end
end

describe Net::IPv6Net, :host_max do
  it 'calculates the correct values' do
    Net::IPv6Net.new('2a02:20:1:2::/64').host_max.should == 0x2a02002000010002ffffffffffffffff
    Net::IPv6Net.new('2a02:20:1:2::0/127').host_max.should == 0x2a020020000100020000000000000001
    Net::IPv6Net.new('2a02:20:1:2::1/128').host_max.should == 0x2a020020000100020000000000000001
  end
end

describe Net::IPv6Net, :include? do
  it 'matches correctly' do
    (Net::IPv6Net.new('2a02:20::1/32').include?('2a02:19::0')).should be_false
    (Net::IPv6Net.new('2a02:20::1/32').include?('2a02:20::0')).should be_true
    (Net::IPv6Net.new('2a02:20::1/32').include?('2a02:20::1')).should be_true
    (Net::IPv6Net.new('2a02:20::1/32').include?('2a02:20:ffff::1')).should be_true
  end
end

describe Net::IPv6Net, :to_s do
  it 'produces correct output' do
    Net::IPv6Net.new('::/0').to_s.should == '::/0'
    Net::IPv6Net.new('2a00::/8').to_s.should == '2a00::/8'
    Net::IPv6Net.new('2aff::0/8').to_s.should == '2a00::/8'
    Net::IPv6Net.new('2a02:20::/32').to_s.should == '2a02:20::/32'
    Net::IPv6Net.new('2a02:20::/127').to_s.should == '2a02:20::/127'
    Net::IPv6Net.new('2a02:20::/128').to_s.should == '2a02:20::/128'
  end
end

describe Net::IPv6Net, 'to_hash' do
  it 'produces correct output' do
    Net::IPv6Net.new('2a02:20::/128').to_hash.should == { :prefix => '2a02:20::', :length => 128 }
  end
end

describe Net::IPv6Net, :== do
  it 'return true if networks are equal' do
    (Net::IPv6Net.new('2a02:20::/32') == '2a02:20::/32').should be_true
  end

  it 'returns false if networks have different prefix' do
    (Net::IPv6Net.new('2a02:20::/32') == '2a02:21::/32').should be_false
  end

  it 'returns false if networks have different prefix length' do
    (Net::IPv6Net.new('2a02:20::/32') == '2a02:20::/31').should be_false
  end
end

describe Net::IPv6Net, :< do
  it 'is false for smaller networks' do
    (Net::IPv6Net.new('2a02:20::/32') < Net::IPv6Net.new('2a02:20::/33')).should be_false
  end

  it 'is false for equal-size networks' do
    (Net::IPv6Net.new('2a02:20::/32') < Net::IPv6Net.new('2a02:20::/32')).should be_false
  end

  it 'is false for non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') < Net::IPv6Net.new('2a02:10::/31')).should be_false
  end

  it 'is true for networks bigger than us with same prefix' do
    (Net::IPv6Net.new('2a02:20::/32') < Net::IPv6Net.new('2a02:20::/31')).should be_true
  end

  it 'is true for networks bigger than us with different but contained prefix' do
    (Net::IPv6Net.new('2a02:20::/32') < Net::IPv6Net.new('2a02:21::/16')).should be_true
  end
end

describe Net::IPv6Net, :<= do
  it 'is false for smaller networks' do
    (Net::IPv6Net.new('2a02:20::/32') <= Net::IPv6Net.new('2a02:20::/33')).should be_false
  end

  it 'is true for equal-size coincident networks' do
    (Net::IPv6Net.new('2a02:20::/32') <= Net::IPv6Net.new('2a02:20::/32')).should be_true
  end

  it 'is false for equal-size non-overlapping networks' do
    (Net::IPv6Net.new('2a02:21::/32') <= Net::IPv6Net.new('2a02:20::/32')).should be_false
  end

  it 'is false for non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') <= Net::IPv6Net.new('2a02:10::/31')).should be_false
  end

  it 'is true for networks bigger than us with same prefix' do
    (Net::IPv6Net.new('2a02:20::/32') <= Net::IPv6Net.new('2a02:20::/31')).should be_true
  end

  it 'is true for networks bigger than us with different but contained prefix' do
    (Net::IPv6Net.new('2a02:20::/32') <= Net::IPv6Net.new('2a02:21::/16')).should be_true
  end
end

describe Net::IPv6Net, :> do
  it 'is false for smaller non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:30::/33')).should be_false
  end

  it 'is true for smaller contained networks' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:20:0::/33')).should be_true
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:20:1::/33')).should be_true
  end

  it 'is false for equal-size networks' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:20::/32')).should be_false
  end

  it 'is false for non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:10::/31')).should be_false
  end

  it 'is false for networks bigger than us with same prefix' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:20::/31')).should be_false
  end

  it 'is false for networks bigger than us with different but contained prefix' do
    (Net::IPv6Net.new('2a02:20::/32') > Net::IPv6Net.new('2a02:21::/16')).should be_false
  end
end

describe Net::IPv6Net, :>= do
  it 'is false for smaller non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:30::/33')).should be_false
  end

  it 'is true for smaller contained networks' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:20:0::/33')).should be_true
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:20:1::/33')).should be_true
  end

  it 'is true for equal-size networks' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:20::/32')).should be_true
  end

  it 'is false for non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:10::/31')).should be_false
  end

  it 'is false for networks bigger than us with same prefix' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:20::/31')).should be_false
  end

  it 'is false for networks bigger than us with different but contained prefix' do
    (Net::IPv6Net.new('2a02:20::/32') >= Net::IPv6Net.new('2a02:21::/16')).should be_false
  end
end

describe Net::IPv6Net, :overlaps do
  it 'is false for smaller non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02:30::/33')).should be_false
  end

  it 'is false for bigger non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02:30::/31')).should be_false
  end

  it 'is false for equal-size non-overlapping networks' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02:30::/32')).should be_false
  end

  it 'is true for same network' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02:20::/32')).should be_true
  end

  it 'is true for bigger network containing us' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02::/16')).should be_true
  end

  it 'is true for smaller network contained' do
    (Net::IPv6Net.new('2a02:20::/32').overlaps('2a02:20:1::/48')).should be_true
  end
end

describe Net::IPv6Net, :>> do
  it 'operates correctly' do
    (Net::IPv6Net.new('2a02:20::/32') >> 1).should == '2a02:20::/33'
  end
end

describe Net::IPv6Net, :<< do
  it 'operates correctly' do
    (Net::IPv6Net.new('2a02:20::/32') << 1).should == '2a02:20::/31'
    (Net::IPv6Net.new('2a02:21::/32') << 1).should == '2a02:20::/31'
  end
end

describe Net::IPv6Net, :=== do
  it 'returns true if other is an IPv6 address and is contained in this network' do
    (Net::IPv6Net.new('2a02:20::/32') === Net::IPv6Addr.new('2a02:20::1')).should be_true
  end

  it 'returns false if other is not IPv6 address' do
    (Net::IPv6Net.new('2a02:20::/32') === 1234).should be_false
  end

  it 'returns false if other is not contained in this network' do
    (Net::IPv6Net.new('2a02:20::/32') === Net::IPv6Addr.new('2a02:ff::1')).should be_false
  end
end
