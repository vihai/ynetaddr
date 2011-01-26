
require 'ynetaddr'

describe Net::IPv4Addr, 'constructor' do
  it 'accepts d.d.d.d format' do
    Net::IPv4Addr.new('1.2.0.255').to_i.should == 0x010200ff
  end

  it 'accepts [d.d.d.d] format' do
    Net::IPv4Addr.new('[1.2.0.255]').to_i.should == 0x010200ff
  end

  it 'accepts integer' do
    Net::IPv4Addr.new(0x01020304).to_i.should == 0x01020304
  end

#  it 'accept d.d.d format' do
#    Net::IPv4Addr.new('1.2.65530').to_i.should == 16908543
#  end
#
#  it 'accept d.d format' do
#    Net::IPv4Addr.new('1.5487554').to_i.should == 16908543
#  end
#
#  it 'accept d format' do
#    Net::IPv4Addr.new('16908543').to_i.should == 16908543
#  end

#  it 'reject invalid octet (>255) values' do
#    lambda { Net::IPv4Addr.new('1.2.0.256') }.should raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d.d' do
#    lambda { Net::IPv4Addr.new('1.2.65536') }.should raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d' do
#    lambda { Net::IPv4Addr.new('1.2.16777216') }.should raise_error(ArgumentError)
#  end

  it 'reject invalid empty address' do
    lambda { Net::IPv4Addr.new('') }.should raise_error(ArgumentError)
  end

  it 'reject invalid empty [] address' do
    lambda { Net::IPv4Addr.new('[]') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::IPv4Addr.new('foo') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::IPv4Addr.new('[foo]') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::IPv4Addr.new('1.2.3.0foo') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::IPv4Addr.new('1.2.3.f0') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Net::IPv4Addr.new('1.2.3.f0') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with consecutive dots' do
    lambda { Net::IPv4Addr.new('1.2..4') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with negative components' do
    lambda { Net::IPv4Addr.new('1.2.-3.4') }.should raise_error(ArgumentError)
  end

end

describe Net::IPv4Addr, :ntoh do
# TODO
end

describe Net::IPv4Addr, :hton do
# TODO
end

describe Net::IPv4Addr, :new_ntoh do
# TODO
end

describe Net::IPv4Addr, :reverse do
  it 'produces reverse mapping name' do
    Net::IPv4Addr.new('1.200.3.255').reverse.should == '255.3.200.1.in-addr.arpa'
  end
end

describe Net::IPv4Addr, :is_rfc1918? do
  it 'returns true for RF1918 addresses' do
    Net::IPv4Addr.new('10.0.0.0').is_rfc1918?.should be_true
    Net::IPv4Addr.new('10.1.2.3').is_rfc1918?.should be_true
    Net::IPv4Addr.new('10.255.255.255').is_rfc1918?.should be_true
    Net::IPv4Addr.new('192.168.0.0').is_rfc1918?.should be_true
    Net::IPv4Addr.new('192.168.1.2').is_rfc1918?.should be_true
    Net::IPv4Addr.new('192.168.255.255').is_rfc1918?.should be_true
    Net::IPv4Addr.new('172.16.0.0').is_rfc1918?.should be_true
    Net::IPv4Addr.new('172.16.1.2').is_rfc1918?.should be_true
    Net::IPv4Addr.new('172.31.255.255').is_rfc1918?.should be_true
  end

  it 'returns false for RF1918 addresses' do
    Net::IPv4Addr.new('9.255.255.255').is_rfc1918?.should be_false
    Net::IPv4Addr.new('11.0.0.0').is_rfc1918?.should be_false
    Net::IPv4Addr.new('192.167.255.255').is_rfc1918?.should be_false
    Net::IPv4Addr.new('192.169.0.0').is_rfc1918?.should be_false
    Net::IPv4Addr.new('172.15.255.255').is_rfc1918?.should be_false
    Net::IPv4Addr.new('172.32.0.0').is_rfc1918?.should be_false
    Net::IPv4Addr.new('224.0.0.0').is_rfc1918?.should be_false
  end
end

describe Net::IPv4Addr, :ipclass do
  it 'returns the correct class' do
    Net::IPv4Addr.new('0.0.0.0').ipclass.should == :a
    Net::IPv4Addr.new('10.0.0.0').ipclass.should == :a
    Net::IPv4Addr.new('127.255.255.255').ipclass.should == :a
    Net::IPv4Addr.new('128.0.0.0').ipclass.should == :b
    Net::IPv4Addr.new('172.16.0.0').ipclass.should == :b
    Net::IPv4Addr.new('191.255.255.255').ipclass.should == :b
    Net::IPv4Addr.new('192.0.0.0').ipclass.should == :c
    Net::IPv4Addr.new('192.168.0.0').ipclass.should == :c
    Net::IPv4Addr.new('223.255.255.255').ipclass.should == :c
    Net::IPv4Addr.new('224.0.0.0').ipclass.should == :d
    Net::IPv4Addr.new('224.1.2.3').ipclass.should == :d
    Net::IPv4Addr.new('239.255.255.255').ipclass.should == :d
    Net::IPv4Addr.new('240.0.0.0').ipclass.should == :e
    Net::IPv4Addr.new('245.0.0.0').ipclass.should == :e
    Net::IPv4Addr.new('255.255.255.255').ipclass.should == :e
  end
end

describe Net::IPv4Addr, :unicast? do
  it 'returns true if the address is unicast' do
    Net::IPv4Addr.new('0.0.0.0').unicast?.should == true
    Net::IPv4Addr.new('10.0.0.0').unicast?.should == true
    Net::IPv4Addr.new('127.255.255.255').unicast?.should == true
    Net::IPv4Addr.new('128.0.0.0').unicast?.should == true
    Net::IPv4Addr.new('172.16.0.0').unicast?.should == true
    Net::IPv4Addr.new('191.255.255.255').unicast?.should == true
    Net::IPv4Addr.new('192.0.0.0').unicast?.should == true
    Net::IPv4Addr.new('192.168.0.0').unicast?.should == true
    Net::IPv4Addr.new('223.255.255.255').unicast?.should == true
  end

  it 'returns false if the address is not unicast' do
    Net::IPv4Addr.new('224.0.0.0').unicast?.should == false
    Net::IPv4Addr.new('224.1.2.3').unicast?.should == false
    Net::IPv4Addr.new('239.255.255.255').unicast?.should == false
    Net::IPv4Addr.new('240.0.0.0').unicast?.should == false
    Net::IPv4Addr.new('245.0.0.0').unicast?.should == false
    Net::IPv4Addr.new('255.255.255.255').unicast?.should == false
  end
end

describe Net::IPv4Addr, :multicast? do
  it 'returns true if the address is multicast' do
    Net::IPv4Addr.new('224.0.0.0').multicast?.should == true
    Net::IPv4Addr.new('224.1.2.3').multicast?.should == true
    Net::IPv4Addr.new('239.255.255.255').multicast?.should == true
  end

  it 'returns false if address is not multicast' do
    Net::IPv4Addr.new('0.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('10.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('127.255.255.255').multicast?.should == false
    Net::IPv4Addr.new('128.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('172.16.0.0').multicast?.should == false
    Net::IPv4Addr.new('191.255.255.255').multicast?.should == false
    Net::IPv4Addr.new('192.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('192.168.0.0').multicast?.should == false
    Net::IPv4Addr.new('223.255.255.255').multicast?.should == false
    Net::IPv4Addr.new('240.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('245.0.0.0').multicast?.should == false
    Net::IPv4Addr.new('255.255.255.255').multicast?.should == false
  end
end

describe Net::IPv4Addr, :to_s do
  it 'produces correct output for addresses starting with 0' do
    Net::IPv4Addr.new('0.0.0.0').to_s.should == '0.0.0.0'
  end
end

describe Net::IPv4Addr, :to_s_bracketed do
  it 'produces bracketed output' do
    Net::IPv4Addr.new('1.2.3.4').to_s_bracketed.should == '[1.2.3.4]'
  end
end


# Parent-class methods

describe Net::IPv4Addr, :included_in? do
  it 'calculates the correct values' do
    Net::IPv4Addr.new('1.2.3.4').included_in?(Net::IPv4Net.new('0.0.0.0/0')).should be_true
    Net::IPv4Addr.new('0.0.0.0').included_in?(Net::IPv4Net.new('0.0.0.0/0')).should be_true
    Net::IPv4Addr.new('255.255.255.255').included_in?(Net::IPv4Net.new('0.0.0.0/0')).should be_true
    Net::IPv4Addr.new('9.255.255.255').included_in?(Net::IPv4Net.new('10.0.0.0/8')).should be_false
    Net::IPv4Addr.new('10.0.0.0').included_in?(Net::IPv4Net.new('10.0.0.0/8')).should be_true
    Net::IPv4Addr.new('10.255.255.255').included_in?(Net::IPv4Net.new('10.0.0.0/8')).should be_true
    Net::IPv4Addr.new('11.0.0.0').included_in?(Net::IPv4Net.new('10.0.0.0/8')).should be_false
  end
end

describe Net::IPv4Addr, :succ do
  it 'returns a Net::IPv4Addr' do
    Net::IPv4Addr.new('1.2.3.4').succ.should be_an_instance_of(Net::IPv4Addr)
  end

  it 'calculates the correct values' do
    Net::IPv4Addr.new('1.2.3.4').succ.should == Net::IPv4Addr.new('1.2.3.5')
    Net::IPv4Addr.new('192.168.255.255').succ.should == Net::IPv4Addr.new('192.169.0.0')
  end
end

describe Net::IPv4Addr, :== do
  it 'return true for equal addresses' do
    (Net::IPv4Addr.new('1.2.3.4') == Net::IPv4Addr.new('1.2.3.4')).should be_true
    (Net::IPv4Addr.new('0.0.0.0') == Net::IPv4Addr.new('0.0.0.0')).should be_true
    (Net::IPv4Addr.new('0.0.0.1') == Net::IPv4Addr.new('0.0.0.1')).should be_true
    (Net::IPv4Addr.new('255.255.255.255') == Net::IPv4Addr.new('255.255.255.255')).should be_true
  end

  it 'return false for different adddresses' do
    (Net::IPv4Addr.new('1.2.3.4') == Net::IPv4Addr.new('0.0.0.0')).should be_false
    (Net::IPv4Addr.new('1.2.3.4') == Net::IPv4Addr.new('255.255.255.255')).should be_false
    (Net::IPv4Addr.new('1.2.3.4') == Net::IPv4Addr.new('1.2.3.5')).should be_false
    (Net::IPv4Addr.new('0.0.0.0') == Net::IPv4Addr.new('255.255.255.255')).should be_false
    (Net::IPv4Addr.new('255.255.255.255') == Net::IPv4Addr.new('0.0.0.0')).should be_false
  end
end

describe Net::IPv4Addr, '!=' do
  it 'returns true for different adddresses' do
    (Net::IPv4Addr.new('1.2.3.4') != Net::IPv4Addr.new('255.255.255.255')).should be_true
    (Net::IPv4Addr.new('1.2.3.4') != Net::IPv4Addr.new('1.2.3.5')).should be_true
    (Net::IPv4Addr.new('0.0.0.0') != Net::IPv4Addr.new('255.255.255.255')).should be_true
    (Net::IPv4Addr.new('255.255.255.255') != Net::IPv4Addr.new('0.0.0.0')).should be_true
  end

  it 'returns false for equal addresses' do
    (Net::IPv4Addr.new('1.2.3.4') != Net::IPv4Addr.new('1.2.3.4')).should be_false
    (Net::IPv4Addr.new('0.0.0.0') != Net::IPv4Addr.new('0.0.0.0')).should be_false
    (Net::IPv4Addr.new('0.0.0.1') != Net::IPv4Addr.new('0.0.0.1')).should be_false
    (Net::IPv4Addr.new('255.255.255.255') != Net::IPv4Addr.new('255.255.255.255')).should be_false
    (Net::IPv4Addr.new('1.2.3.4') != Net::IPv4Addr.new('0.0.0.0')).should be_true
  end
end

describe Net::IPv4Addr, :<=> do
  it 'returns a kind of Integer' do
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('1.2.3.4')).should be_a_kind_of(Integer)
  end

  it 'compares correctly' do
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('1.2.3.4')).should == 0
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('1.2.3.5')).should == -1
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('1.2.3.3')).should == 1
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('0.0.0.0')).should == 1
    (Net::IPv4Addr.new('1.2.3.4') <=> Net::IPv4Addr.new('255.255.255.255')).should == -1
  end
end

describe Net::IPv4Addr, :+ do
  it 'returns of type Net::IPv4Addr' do
    (Net::IPv4Addr.new('1.2.3.4') + 1).should be_an_instance_of(Net::IPv4Addr)
  end

  it 'sums correctly' do
    (Net::IPv4Addr.new('1.2.3.4') + 1).should == Net::IPv4Addr.new('1.2.3.5')
    (Net::IPv4Addr.new('1.2.3.4') + (-1)).should == Net::IPv4Addr.new('1.2.3.3')
    (Net::IPv4Addr.new('1.2.3.4') + 10).should == Net::IPv4Addr.new('1.2.3.14')
  end
end

describe Net::IPv4Addr, :- do
  it 'returns of type Net::IPv4Addr' do
    (Net::IPv4Addr.new('1.2.3.4') - 1).should be_an_instance_of(Net::IPv4Addr)
  end

  it 'subtracts correctly' do
    (Net::IPv4Addr.new('1.2.3.4') - 1).should == Net::IPv4Addr.new('1.2.3.3')
    (Net::IPv4Addr.new('1.2.3.4') - (-1)).should == Net::IPv4Addr.new('1.2.3.5')
    (Net::IPv4Addr.new('1.2.3.4') - 10).should == Net::IPv4Addr.new('1.2.2.250')
  end
end

describe Net::IPv4Addr, :| do
  it 'returns of type Net::IPv4Addr' do
    (Net::IPv4Addr.new(0x00000000) | 0x0000ffff).should be_an_instance_of(Net::IPv4Addr)
  end

  it 'operates correctly'do
    (Net::IPv4Addr.new(0x00000000) | 0x0000ffff).should == 0x0000ffff
  end
end

describe Net::IPv4Addr, :& do
  it 'returns of type Net::IPv4Addr' do
    (Net::IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff).should be_an_instance_of(Net::IPv4Addr)
  end

  it 'operates correctly' do
    (Net::IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff).should == 0x00000f0f
  end
end

describe Net::IPv4Addr, :mask do
  it 'returns of type Net::IPv4Addr' do
    (Net::IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000)).should be_an_instance_of(Net::IPv4Addr)
  end

  it 'masks correctly' do
    (Net::IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000)).should == 0x0f0f0000
  end
end

describe Net::IPv4Addr, :mask! do
  it 'returns self' do
    a = Net::IPv4Addr.new('1.2.3.4')
    a.mask!(0xffff0000).should be_equal(a)
  end

  it 'masks correctly' do
    a = Net::IPv4Addr.new(0x0f0f0f0f)
    a.to_i.should == 0x0f0f0f0f
    a.mask!(0xffff0000)
    a.to_i.should == 0x0f0f0000
  end
end

describe Net::IPv4Addr, :to_i do
  it 'returns a kind of Integer' do
    Net::IPv4Addr.new('1.2.3.4').to_i.should be_a_kind_of(Integer)
  end

  it 'converts to integer' do
    Net::IPv4Addr.new(0x0f0f0f0f).to_i.should == 0x0f0f0f0f
  end
end

describe Net::IPv4Addr, :hash do
  it 'returns a kind of Integer' do
    Net::IPv4Addr.new('1.2.3.4').hash.should be_a_kind_of(Integer)
  end

  it 'produces a hash' do
    Net::IPv4Addr.new(0x0f0f0f0f).to_i.should == 0x0f0f0f0f
  end
end

