
require 'ynetaddr'

module Net

describe IPTree, 'constructor' do
  it 'creates a new tree with specified network' do
    IPTree.new('2a02:20:1:2::/64').network.should == IPv6Net.new('2a02:20:1:2::/64')
  end

  it 'created node with specified network should be marked as used' do
    IPTree.new('2a02:20:1:2::/64').used.should be_true
  end
end

describe IPTree, :add do
  it 'adds specified networks and produces correct tree' do
    net = IPTree.new('::/0')
    net.add('2a02::/16')
    net.add('2a02:8000::/17')
    net.add('2a02:20::/32')
    net.add('2a02:21::/32')

    net.used.should be_true

    net.l.network.should == '::/1'
    net.l.used.should be_false
    net.r.should be_nil

    net.l.l.network.should == '::/2'
    net.l.l.used.should be_false
    net.l.r.should be_nil

    net.l.l.l.should be_nil
    net.l.l.r.network.should == '2000::/3'
    net.l.l.r.used.should be_false

    net.l.l.r.l.network.should == '2000::/4'
    net.l.l.r.l.used.should be_false
    net.l.l.r.r.should be_nil

    net.l.l.r.l.l.should be_nil
    net.l.l.r.l.r.network.should == '2800::/5'
    net.l.l.r.l.r.used.should be_false

    net.l.l.r.l.r.l.network.should == '2800::/6'
    net.l.l.r.l.r.l.used.should be_false
    net.l.l.r.l.r.r.should be_nil

    net.l.l.r.l.r.l.l.should be_nil
    net.l.l.r.l.r.l.r.network.should == '2a00::/7'
    net.l.l.r.l.r.l.r.used.should be_false

    net.l.l.r.l.r.l.r.l.network.should == '2a00::/8'
    net.l.l.r.l.r.l.r.l.used.should be_false
    net.l.l.r.l.r.l.r.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.network.should == '2a00::/9'
    net.l.l.r.l.r.l.r.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.network.should == '2a00::/10'
    net.l.l.r.l.r.l.r.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.network.should == '2a00::/11'
    net.l.l.r.l.r.l.r.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.network.should == '2a00::/12'
    net.l.l.r.l.r.l.r.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.network.should == '2a00::/13'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.network.should == '2a00::/14'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.l.should be_nil
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.network.should == '2a02::/15'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.used.should be_false

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.network.should == '2a02::/16'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.used.should be_true
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.network.should == '2a02::/17'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.network.should == '2a02:8000::/17'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.used.should be_true

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.network.should == '2a02::/18'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.l.should be_nil
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.network.should == '2a02::/19'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.network.should == '2a02::/20'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.network.should == '2a02::/21'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.network.should == '2a02::/22'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.network.should == '2a02::/23'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.network.should == '2a02::/24'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.network.should == '2a02::/25'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.network.should == '2a02::/26'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.l.should be_nil
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.network.should == '2a02:20::/27'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.used.should be_false

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.network.should == '2a02:20::/28'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.network.should == '2a02:20::/29'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.network.should == '2a02:20::/30'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.network.should == '2a02:20::/31'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.used.should be_false
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.network.should == '2a02:20::/32'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.used.should be_true
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.network.should == '2a02:21::/32'
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.used.should be_true

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.l.should be_nil
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.r.should be_nil

    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.l.should be_nil
    net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.r.should be_nil
  end

  it 'raises an error if the same network is added twice' do
    net = IPTree.new('::/0')
    net.add('2a02::/16')
    net.add('2a02:8000::/17')
    net.add('2a02:20::/32')
    net.add('2a02:21::/32')
    lambda { net.add('2a02:21::/32') }.should raise_error(ArgumentError)
  end

  it 'raises an error if a network outside the tree is added' do
    net = IPTree.new('2a02:20::/32')
    lambda { net.add('8888::/32') }.should raise_error(ArgumentError)
  end
end

describe IPTree, :networks do
  it '' do
    pending
  end
end

describe IPTree, :free_space do
  it '' do
    pending
  end
end

describe IPTree, :pick_free do
  it '' do
    pending
  end
end

describe IPTree, :to_s do
  it '' do
    pending
  end
end

end
