#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

describe IPNet do

describe :new do
  it 'instantiate an IPv4Net when string is compatible with an IPv4 net' do
    expect(IPNet.new('192.168.0.0/24')).to be_a(IPv4Net)
  end

  it 'instantiate an IPv6Net when string is compatible with an IPv6 net' do
    expect(IPNet.new('2a02:20::/32')).to be_a(IPv6Net)
  end
end

end

end
