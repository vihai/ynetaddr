#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPIfAddr do

describe :new do
  it 'instantiate an IPv4IfAddr when string is compatible with an IPv4 addr' do
    expect(IPIfAddr.new('192.168.0.1/24')).to be_a(IPv4IfAddr)
  end

  it 'instantiate an IPv6IfAddr when string is compatible with an IPv6 addr' do
    expect(IPIfAddr.new('2a02:20::1/64')).to be_a(IPv6IfAddr)
  end
end

end

end
