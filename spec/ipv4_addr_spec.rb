
require File.expand_path('../../lib/netaddr', __FILE__)

describe Netaddr::IPv4Addr, 'constructor' do
  it 'accepts d.d.d.d format' do
    Netaddr::IPv4Addr.new('1.2.0.255').to_i.should == 0x010200ff
  end

  it 'accepts [d.d.d.d] format' do
    Netaddr::IPv4Addr.new('[1.2.0.255]').to_i.should == 0x010200ff
  end

  it 'accepts integer' do
    Netaddr::IPv4Addr.new(0x01020304).to_i.should == 0x01020304
  end

#  it 'accept d.d.d format' do
#    Netaddr::IPv4Addr.new('1.2.65530').to_i.should == 16908543
#  end
#
#  it 'accept d.d format' do
#    Netaddr::IPv4Addr.new('1.5487554').to_i.should == 16908543
#  end
#
#  it 'accept d format' do
#    Netaddr::IPv4Addr.new('16908543').to_i.should == 16908543
#  end

#  it 'reject invalid octet (>255) values' do
#    lambda { Netaddr::IPv4Addr.new('1.2.0.256') }.should raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d.d' do
#    lambda { Netaddr::IPv4Addr.new('1.2.65536') }.should raise_error(ArgumentError)
#  end
#
#  it 'reject invalid component values with format d.d' do
#    lambda { Netaddr::IPv4Addr.new('1.2.16777216') }.should raise_error(ArgumentError)
#  end

  it 'reject invalid empty address' do
    lambda { Netaddr::IPv4Addr.new('') }.should raise_error(ArgumentError)
  end

  it 'reject invalid empty [] address' do
    lambda { Netaddr::IPv4Addr.new('[]') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::IPv4Addr.new('foo') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::IPv4Addr.new('[foo]') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::IPv4Addr.new('1.2.3.0foo') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::IPv4Addr.new('1.2.3.f0') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::IPv4Addr.new('1.2.3.f0') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with consecutive dots' do
    lambda { Netaddr::IPv4Addr.new('1.2..4') }.should raise_error(ArgumentError)
  end

  it 'reject invalid address with negative components' do
    lambda { Netaddr::IPv4Addr.new('1.2.-3.4') }.should raise_error(ArgumentError)
  end

end

describe Netaddr::IPv4Addr, :to_s do
  it 'produces correct output for addresses starting with 0' do
    Netaddr::IPv4Addr.new('0.0.0.0').to_s.should == '0.0.0.0'
  end
end


# Parent-class methods

describe Netaddr::IPv4Addr, :included_in? do
#TODO
end

describe Netaddr::IPv4Addr, :succ do
#TODO
end

describe Netaddr::IPv4Addr, :== do
#TODO
end

describe Netaddr::IPv4Addr, :<=> do
#TODO
end

describe Netaddr::IPv4Addr, :+ do
#TODO
end

describe Netaddr::IPv4Addr, :- do
#TODO
end

describe Netaddr::IPv4Addr, :| do
#TODO
end

describe Netaddr::IPv4Addr, :& do
#TODO
end

describe Netaddr::IPv4Addr, :mask do
#TODO
end

describe Netaddr::IPv4Addr, :mask! do
#TODO
end

describe Netaddr::IPv4Addr, :to_i do
#TODO
end

describe Netaddr::IPv4Addr, :hash do
#TODO
end

