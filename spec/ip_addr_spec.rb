require 'ynetaddr'

module Net

describe IPAddr do

describe :new do
  it 'instantiate an IPv4Addr when string is compatible with an IPv4 addr' do
    expect(IPAddr.new('192.168.0.1')).to be_a(IPv4Addr)
  end

  it 'instantiate an IPv6Addr when string is compatible with an IPv6 addr' do
    expect(IPAddr.new('2a02:20::1')).to be_a(IPv6Addr)
  end
end

end

end
