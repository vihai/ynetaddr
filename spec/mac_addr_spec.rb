
require File.expand_path('../../lib/netaddr', __FILE__)

describe Netaddr::MacAddr, 'constructor' do
  it 'accepts hhhh.hhhh.hhhh format' do
    Netaddr::MacAddr.new('0012.3456.789a').to_i.should == 0x00123456789a
  end

  it 'accepts hh:hh:hh:hh:hh:hh format' do
    Netaddr::MacAddr.new('00:12:34:56:78:9a').to_i.should == 0x00123456789a
  end

  it 'accepts integer' do
    Netaddr::MacAddr.new(0x00123456789a).to_i.should == 0x00123456789a
  end

  it 'reject invalid empty address' do
    lambda { Netaddr::MacAddr.new('') }.should raise_error(Netaddr::MacAddr::InvalidFormat)
  end

  it 'reject invalid address with alphanumeric chars' do
    lambda { Netaddr::MacAddr.new('0012.3456.fbar') }.should raise_error(Netaddr::MacAddr::InvalidFormat)
  end

end
