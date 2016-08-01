
require 'ynetaddr'

module Net

describe IPTree, 'constructor' do
  it 'creates a new tree with specified network' do
    expect(IPTree.new('2a02:20:1:2::/64').network).to eq(IPv6Net.new('2a02:20:1:2::/64'))
  end

  it 'created node with specified network should not be marked as used' do
    expect(IPTree.new('2a02:20:1:2::/64').used).to be_falsey
  end

  it 'initializes from array' do
    expect(IPTree.new(['0.0.0.0/0', '62.212.0.0/24', '10.0.0.0/24']).used).to be_falsey
  end
end

describe IPTree, :add do
  it 'adds specified networks and produces correct tree' do
    net = IPTree.new('::/0')
    net.add('2a02::/16')
    net.add('2a02:8000::/17')
    net.add('2a02:20::/32')
    net.add('2a02:21::/32')

    expect(net.used).to be_falsey

    expect(net.l.network).to eq('::/1')
    expect(net.l.used).to be_falsey
    expect(net.r).to be_nil

    expect(net.l.l.network).to eq('::/2')
    expect(net.l.l.used).to be_falsey
    expect(net.l.r).to be_nil

    expect(net.l.l.l).to be_nil
    expect(net.l.l.r.network).to eq('2000::/3')
    expect(net.l.l.r.used).to be_falsey

    expect(net.l.l.r.l.network).to eq('2000::/4')
    expect(net.l.l.r.l.used).to be_falsey
    expect(net.l.l.r.r).to be_nil

    expect(net.l.l.r.l.l).to be_nil
    expect(net.l.l.r.l.r.network).to eq('2800::/5')
    expect(net.l.l.r.l.r.used).to be_falsey

    expect(net.l.l.r.l.r.l.network).to eq('2800::/6')
    expect(net.l.l.r.l.r.l.used).to be_falsey
    expect(net.l.l.r.l.r.r).to be_nil

    expect(net.l.l.r.l.r.l.l).to be_nil
    expect(net.l.l.r.l.r.l.r.network).to eq('2a00::/7')
    expect(net.l.l.r.l.r.l.r.used).to be_falsey

    expect(net.l.l.r.l.r.l.r.l.network).to eq('2a00::/8')
    expect(net.l.l.r.l.r.l.r.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.network).to eq('2a00::/9')
    expect(net.l.l.r.l.r.l.r.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.network).to eq('2a00::/10')
    expect(net.l.l.r.l.r.l.r.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.network).to eq('2a00::/11')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.network).to eq('2a00::/12')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.network).to eq('2a00::/13')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.network).to eq('2a00::/14')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.l).to be_nil
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.network).to eq('2a02::/15')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.used).to be_falsey

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.network).to eq('2a02::/16')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.used).to be_truthy
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.network).to eq('2a02::/17')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.network).to eq('2a02:8000::/17')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.used).to be_truthy

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.network).to eq('2a02::/18')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.l).to be_nil
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.r.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.network).to eq('2a02::/19')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.network).to eq('2a02::/20')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.network).to eq('2a02::/21')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.network).to eq('2a02::/22')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.network).to eq('2a02::/23')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.network).to eq('2a02::/24')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.network).to eq('2a02::/25')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.network).to eq('2a02::/26')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.l).to be_nil
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.network).to eq('2a02:20::/27')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.used).to be_falsey

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.network).to eq('2a02:20::/28')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.network).to eq('2a02:20::/29')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.network).to eq('2a02:20::/30')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.network).to eq('2a02:20::/31')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.used).to be_falsey
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.network).to eq('2a02:20::/32')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.used).to be_truthy
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.network).to eq('2a02:21::/32')
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.used).to be_truthy

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.l).to be_nil
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.l.r).to be_nil

    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.l).to be_nil
    expect(net.l.l.r.l.r.l.r.l.l.l.l.l.l.l.r.l.l.l.l.l.l.l.l.l.l.l.r.l.l.l.l.r.r).to be_nil
  end

  it 'raises an error if the same network is added twice' do
    net = IPTree.new('::/0')
    net.add('2a02::/16')
    net.add('2a02:8000::/17')
    net.add([ '2a02:20::/32', '2a02:21::/32' ])
    expect { net.add('2a02:21::/32') }.to raise_error(IPTree::NetworkAlreadyPresent)
  end

  it 'raises an error if a network outside the tree is added' do
    net = IPTree.new('2a02:20::/32')
    expect { net.add('8888::/32') }.to raise_error(IPTree::NetworkNotContained)
  end
end

describe IPTree, :networks do
  it 'should return inserted networks' do
    net = IPTree.new(['::/0', '2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(net.networks.sort).to eq([ '2a02:20::/32', '2a02:21::/32', '2a02:8000::/17', '2a02::/16' ])
  end
end

describe IPTree, :find do
  it 'returns the found network' do
    net = IPTree.new(['::/0', '2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(net.find('2a02::/16')).to be_a(IPTree)
    expect(net.find('2a02::/16').network).to eq('2a02::/16')
  end
end

describe IPTree, :free_space do
  it 'returns free space' do
    net = IPTree.new('::/0')
    net.add([ 'f000::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(net.free_space.sort).to eq(
      ['2a02:22::/31', '2a02:24::/30', '2a02:28::/29', '2a02:30::/28', '2a02::/27', '2a02:40::/26', '2a02:80::/25',
       '2a02:100::/24', '2a02:200::/23', '2a02:400::/22', '2a02:800::/21', '2a02:1000::/20', '2a02:2000::/19', '2a02:4000::/18',
       '2a03::/16', 'f001::/16', '2a00::/15', 'f002::/15', '2a04::/14', 'f004::/14', '2a08::/13', 'f008::/13', '2a10::/12',
       'f010::/12', '2a20::/11', 'f020::/11', '2a40::/10', 'f040::/10', '2a80::/9', 'f080::/9', '2b00::/8', 'f100::/8',
       '2800::/7', 'f200::/7', '2c00::/6', 'f400::/6', '2000::/5', 'f800::/5', '3000::/4', 'e000::/4', '::/3', 'c000::/3',
       '4000::/2', '8000::/2'])
  end

  it 'returns free space (case 2)' do
    net = IPTree.new('195.72.212.0/24')
    net.add([ '195.72.212.0/28', '195.72.212.16/29', '195.72.212.48/29', '195.72.212.64/26',
              '195.72.212.240/30', '195.72.212.248/29' ])
    expect(net.free_space(28).sort).to eq(
      [ '195.72.212.32/28', '195.72.212.224/28', '195.72.212.192/27', '195.72.212.128/26', ])

  end
end

describe IPTree, :pick_free do
  it 'picks smallest free network' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(tree.pick_free(64)).to eq('2a02:22::/64')
  end

  it 'picks next smallest free network' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    free = tree.pick_free(64)
    expect(free).to eq('2a02:22::/64')
    tree.add(free)
    expect(tree.pick_free(64)).to eq('2a02:22:0:1::/64')
  end

  it 'considers range specifications (with range overlapping busy net at the left)' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(tree.pick_free(64, '2a02:7ff0::'..'2a02:8010::')).to eq('2a02:7ff0::/64')
  end

  it 'considers range specifications (with range overlapping busy net at the right)' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(tree.pick_free(64, '2a02:21:fff0::'..'2a02:22:10::')).to eq('2a02:22::/64')
  end

  it 'considers range specifications (with range including busy net)' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(tree.pick_free(64, '2a02:1f::'..'2a02:23::')).to eq('2a02:22::/64')
  end

  it 'considers range specifications (with range withing busy net)' do
    tree = IPTree.new(['2a02::/16', '2a02:8000::/17', '2a02:20::/32', '2a02:21::/32' ])
    expect(tree.pick_free(64, '2a02:20:10::'..'2a02:20:11::')).to be_nil
  end
end

end
