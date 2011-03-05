
require 'ynetaddr'

module Net

describe IPNet, :net do
  it 'instantiate an IPv4Net when string is compatible with an IPv4 net' do
    IPNet.new('192.168.0.0/24').should be_a(IPv4Net)
  end

  it 'instantiate an IPv6Net when string is compatible with an IPv6 net' do
    IPNet.new('2a02:20::/32').should be_a(IPv6Net)
  end
end

end
