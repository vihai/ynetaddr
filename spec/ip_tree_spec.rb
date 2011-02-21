
require 'ynetaddr'

module Net

describe IPTree, 'constructor' do
  it 'creates a new tree with specified network' do
    IPTree.new('2a02:20:1:2::/64').network.should == IPv6Net.new('2a02:20:1:2::/64')
  end

  it 'created node with specified network should not be marked as used' do
    IPTree.new('2a02:20:1:2::/64').used.should be_false
  end

  it 'initializes from array' do
    IPTree.new(['0.0.0.0/0', '62.212.0.0/24', '10.0.0.0/24']).used.should be_false
  end
end

describe IPTree, :add do
  it 'adds specified networks and produces correct tree' do
    net = IPTree.new('::/0')
    net.add('2a02::/16')
    net.add('2a02:8000::/17')
    net.add('2a02:20::/32')
    net.add('2a02:21::/32')

    net.used.should be_false

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
    net.add([ '2a02:20::/32', '2a02:21::/32' ])
    lambda { net.add('2a02:21::/32') }.should raise_error(ArgumentError)
  end

  it 'raises an error if a network outside the tree is added' do
    net = IPTree.new('2a02:20::/32')
    lambda { net.add('8888::/32') }.should raise_error(ArgumentError)
  end
end

describe IPTree, :networks do
  it 'should return inserted networks' do
    net = IPTree.new(['::/0', '2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    net.networks.sort.should == [ '2a02:20::/32', '2a02:21::/32', '2a02:8000::/17', '2a02::/16' ]
  end
end

describe IPTree, :find do
  it 'returns the found network' do
    net = IPTree.new(['::/0', '2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    net.find('2a02::/16').should be_a(IPTree)
    net.find('2a02::/16').network.should == '2a02::/16'
  end
end

describe IPTree, :free_space do
  it 'returns free space' do
    net = IPTree.new('::/0')
    net.add([ 'f000::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    net.free_space.sort.should ==
      ['2a02:22::/31', '2a02:24::/30', '2a02:28::/29', '2a02:30::/28', '2a02::/27', '2a02:40::/26', '2a02:80::/25',
       '2a02:100::/24', '2a02:200::/23', '2a02:400::/22', '2a02:800::/21', '2a02:1000::/20', '2a02:2000::/19', '2a02:4000::/18',
       '2a03::/16', 'f001::/16', '2a00::/15', 'f002::/15', '2a04::/14', 'f004::/14', '2a08::/13', 'f008::/13', '2a10::/12',
       'f010::/12', '2a20::/11', 'f020::/11', '2a40::/10', 'f040::/10', '2a80::/9', 'f080::/9', '2b00::/8', 'f100::/8',
       '2800::/7', 'f200::/7', '2c00::/6', 'f400::/6', '2000::/5', 'f800::/5', '3000::/4', 'e000::/4', '::/3', 'c000::/3',
       '4000::/2', '8000::/2']
  end
end

describe IPTree, :pick_free do
  it 'picks smallest free network' do
    net = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    net.pick_free(64).should == '2a02:22::/64'
  end
end

describe IPTree, :pick_free do
  it 'picks next smallest free network' do
    net = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    net.pick_free(64).should == '2a02:22::/64'
    net.pick_free(64).should == '2a02:22:0:1::/64'
  end
end

end
