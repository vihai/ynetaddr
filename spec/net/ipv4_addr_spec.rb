#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ynetaddr'

module Net

RSpec.describe IPv4Addr do

describe 'constructor' do
  let(:all_off) {
    {
     dotquad: false, dotquad_dec: false, dotquad_hex: false, dotquad_oct: false,
     sq_brackets: false,
     decimal: false,
     hexadecimal: false
    }
  }


  context 'with a non-keyword parameter' do
    it 'initializes from integer' do
      expect(IPv4Addr.new(0x01020304).to_i).to eq(0x01020304)
    end

    context 'without square brackets' do
      it 'reject invalid empty address' do
        expect { IPv4Addr.new('') }.to raise_error(ArgumentError)
      end

      it 'reject invalid address with consecutive dots' do
        expect { IPv4Addr.new('1.2..4') }.to raise_error(FormatNotRecognized)
      end

      context 'dotquad decimal (d.d.d.d)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('1.2.0.255').to_i).to eq(0x010200ff)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('1.2.0.255', **all_off.merge(dotquad: true, dotquad_dec: true)).to_i).to eq(0x010200ff)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('1.2.0.255', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_dec is excluded form supported formats' do
          expect { IPv4Addr.new('1.2.0.255', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-decimal characters are present' do
          expect { IPv4Addr.new('1.2.0.255f', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('1.2.f0.255', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('1.2.0.255😡', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('foo', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        end
      end

      context 'dotquad hexadecimal (h.h.h.h)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('0x22.0x33.0x44.0x55').to_i).to eq(0x22334455)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('0x22.0x33.0x44.0x55', **all_off.merge(dotquad: true, dotquad_hex: true)).to_i).to eq(0x22334455)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('0x22.0x33.0x44.0x55', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_hex is excluded form supported formats' do
          expect { IPv4Addr.new('0x22.0x33.0x44.0x55', dotquad_hex: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-hex characters are present' do
          expect { IPv4Addr.new('-0x22.0x33.0x44.0x55') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('0x22.0x33.-0x44.0x55') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('0x22.0x33.0x44.0xgg') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('0x22.0x33.0x44.0x😡') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'dotquad octal (o.o.o.o)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('022.033.044.055').to_i).to eq(303768621)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('022.033.044.055', **all_off.merge(dotquad: true, dotquad_oct: true)).to_i).to eq(303768621)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('022.033.044.055', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_oct is excluded form supported formats' do
          expect { IPv4Addr.new('022.033.044.055', dotquad_oct: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-octal characters are present' do
          expect { IPv4Addr.new('-022.033.044.055') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('022.033.-044.055') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('022.033.044.0gg') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('022.033.044.078') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('022.033.044.0😡') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'decimal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('16384576').to_i).to eq(16384576)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('16384576', **all_off.merge(sq_brackets: true, decimal: true)).to_i).to eq(16384576)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('16384576', decimal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('-16384576') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('16384576a') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('a16384576') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('aaa') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('😡') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'hexadecimal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('0x1234abcd').to_i).to eq(0x1234abcd)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('0x1234abcd', **all_off.merge(sq_brackets: true, hexadecimal: true)).to_i).to eq(0x1234abcd)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('0x1234abcd', hexadecimal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('-0x1234abcd') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('0x1234abcG') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('a0x1234abc') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('aaa') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('😡') }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing numbers greater than 2^32' do
          expect { IPv4Addr.new('0x1234abcde') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'octal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[0123456]').to_i).to eq(0123456)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('[0123456]', **all_off.merge(sq_brackets: true, octal: true)).to_i).to eq(0123456)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('[0123456]', octal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('[-0123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0123456a]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[a0123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0a123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[aaa]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[😡]') }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing numbers greater than 2^32' do
          expect { IPv4Addr.new('012345601234560123456') }.to raise_error(FormatNotRecognized)
        end
      end
    end

    context 'with square brackets' do
      it 'reject invalid empty [] address' do
        expect { IPv4Addr.new('[]') }.to raise_error(ArgumentError)
      end

      it 'reject invalid address with consecutive dots' do
        expect { IPv4Addr.new('[1.2..4]') }.to raise_error(FormatNotRecognized)
      end

      context 'dotquad decimal (d.d.d.d)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[1.2.0.255]').to_i).to eq(0x010200ff)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('[1.2.0.255]', **all_off.merge(sq_brackets: true, dotquad: true, dotquad_dec: true)).to_i).to eq(0x010200ff)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('[1.2.0.255]', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_dec is excluded form supported formats' do
          expect { IPv4Addr.new('[1.2.0.255]', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-decimal characters are present' do
          expect { IPv4Addr.new('[1.2.0.255f]', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[1.2.f0.255]', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[1.2.0.255😡]', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[foo]', dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        end
      end

      context 'dotquad hexadecimal (h.h.h.h)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[0x22.0x33.0x44.0x55]').to_i).to eq(0x22334455)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('[0x22.0x33.0x44.0x55]', **all_off.merge(sq_brackets: true, dotquad: true, dotquad_hex: true)).to_i).to eq(0x22334455)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_hex is excluded form supported formats' do
          expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', dotquad_hex: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-hex characters are present' do
          expect { IPv4Addr.new('[-0x22.0x33.0x44.0x55]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0x22.0x33.-0x44.0x55]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0x22.0x33.0x44.0xgg]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0x22.0x33.0x44.0x😡]') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'dotquad octal (o.o.o.o)' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[022.033.044.055]').to_i).to eq(303768621)
        end

        it 'is parsed when it is the only supported format' do
          expect(IPv4Addr.new('[022.033.044.055]', **all_off.merge(sq_brackets: true, dotquad: true, dotquad_oct: true)).to_i).to eq(303768621)
        end

        it 'raises a FormatNotRecognized when dotquad is excluded form supported formats' do
          expect { IPv4Addr.new('[022.033.044.055]', dotquad: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when dotquad_oct is excluded form supported formats' do
          expect { IPv4Addr.new('[022.033.044.055]', dotquad_oct: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when non-octal characters are present' do
          expect { IPv4Addr.new('[-022.033.044.055]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[022.033.-044.055]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[022.033.044.0gg]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[022.033.044.078]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[022.033.044.0😡]') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'decimal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[16384576]').to_i).to eq(16384576)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('[16384576]', **all_off.merge(sq_brackets: true, decimal: true)).to_i).to eq(16384576)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('[16384576]', decimal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('[-16384576]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[16384576a]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[a16384576]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[aaa]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[😡]') }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing numbers greater than 2^32' do
          expect { IPv4Addr.new('32432416384576') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'hexadecimal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[0x1234abcd]').to_i).to eq(0x1234abcd)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('[0x1234abcd]', **all_off.merge(sq_brackets: true, hexadecimal: true)).to_i).to eq(0x1234abcd)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('[0x1234abcd]', hexadecimal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('[-0x1234abcd]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0x1234abcG]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[a0x1234abc]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[aaa]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[😡]') }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing numbers greater than 2^32' do
          expect { IPv4Addr.new('0x1234abcde') }.to raise_error(FormatNotRecognized)
        end
      end

      context 'octal string' do
        it 'is parsed by default' do
          expect(IPv4Addr.new('[0123456]').to_i).to eq(0123456)
        end

        it 'is parsed when the only supported format' do
          expect(IPv4Addr.new('[0123456]', **all_off.merge(sq_brackets: true, octal: true)).to_i).to eq(0123456)
        end

        it 'raises an error when not a supported format' do
          expect { IPv4Addr.new('[0123456]', octal: false) }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing non numeric characters' do
          expect { IPv4Addr.new('[-0123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0123456a]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[a0123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[0a123456]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[aaa]') }.to raise_error(FormatNotRecognized)
          expect { IPv4Addr.new('[😡]') }.to raise_error(FormatNotRecognized)
        end

        it 'raises a FormatNotRecognized when containing numbers greater than 2^32' do
          expect { IPv4Addr.new('012345601234560123456') }.to raise_error(FormatNotRecognized)
        end
      end
    end

    context 'with square brackets but disabled' do
      it 'rejects all addresses with brackets' do
        expect { IPv4Addr.new('[]', sq_brackets: false) }.to raise_error(ArgumentError)
        expect { IPv4Addr.new('[1.2..4]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255]', **all_off.merge(sq_brackets: false, dotquad: true, dotquad_dec: true)) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255]', sq_brackets: false, dotquad: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255]', sq_brackets: false, dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255f]', sq_brackets: false, dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.f0.255]', sq_brackets: false, dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[1.2.0.255😡]', sq_brackets: false, dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[foo]', sq_brackets: false, dotquad_dec: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', **all_off.merge(sq_brackets: false, dotquad: true, dotquad_hex: true)) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', sq_brackets: false, dotquad: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0x55]', sq_brackets: false, dotquad_hex: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[-0x22.0x33.0x44.0x55]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.-0x44.0x55]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0xgg]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[0x22.0x33.0x44.0x😡]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.055]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.055]', **all_off.merge(sq_brackets: false, dotquad: true, dotquad_oct: true)) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.055]', sq_brackets: false, dotquad: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.055]', sq_brackets: false, dotquad_oct: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[-022.033.044.055]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.-044.055]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.0gg]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.078]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
        expect { IPv4Addr.new('[022.033.044.0😡]', sq_brackets: false) }.to raise_error(FormatNotRecognized)
      end
    end
  end

  context 'with addr: parameter' do
    it 'parses as usual' do
      expect(IPv4Addr.new(addr: '1.2.0.255').to_i).to eq(0x010200ff)
      expect(IPv4Addr.new(addr: 0x01020304).to_i).to eq(0x01020304)
    end
  end

  context 'with binary: parameter' do
    it 'directly assigns binary value' do
      expect(IPv4Addr.new(binary: 'AEIO').to_i).to eq(0x4145494f)
    end

    it 'rejects a wrong size binary addr' do
      expect { IPv4Addr.new(binary: 'AEIOU') }.to raise_error(FormatNotRecognized)
      expect { IPv4Addr.new(binary: 'AEI') }.to raise_error(FormatNotRecognized)
    end
  end


  require 'ipaddr'
  it 'accepts ::IPAddr' do
    expect(IPv4Addr.new(::IPAddr.new('1.2.3.4')).to_i).to eq(0x01020304)
  end


  it 'raises an ArgumentError if invoked with unknown arguments' do
    expect { IPv4Addr.new(foobar: 'baz') }.to raise_error(ArgumentError)
  end

  it 'accepts an object that responds to to_ipv4addr' do
    expect(IPv4Addr.new(TestObj.new).to_i).to eq(741818957)
  end

end

describe :to_binary do
  it 'returns a binary string representation of the IP address' do
    expect(IPv4Addr.new('11.22.33.44').to_binary).to eq(
      "\x0b\x16\x21\x2c".force_encoding(Encoding::ASCII_8BIT))
  end
end

describe :reverse do
  it 'produces reverse mapping name' do
    expect(IPv4Addr.new('1.200.3.255').reverse).to eq('255.3.200.1.in-addr.arpa')
  end
end

describe :is_rfc1918? do
  it 'returns true for RF1918 addresses' do
    expect(IPv4Addr.new('10.0.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('10.1.2.3').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('10.255.255.255').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.1.2').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('192.168.255.255').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.16.0.0').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.16.1.2').is_rfc1918?).to be_truthy
    expect(IPv4Addr.new('172.31.255.255').is_rfc1918?).to be_truthy
  end

  it 'returns false for RF1918 addresses' do
    expect(IPv4Addr.new('9.255.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('11.0.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('192.167.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('192.169.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('172.15.255.255').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('172.32.0.0').is_rfc1918?).to be_falsey
    expect(IPv4Addr.new('224.0.0.0').is_rfc1918?).to be_falsey
  end
end

describe :ipclass do
  it 'returns the correct class' do
    expect(IPv4Addr.new('0.0.0.0').ipclass).to eq(:a)
    expect(IPv4Addr.new('10.0.0.0').ipclass).to eq(:a)
    expect(IPv4Addr.new('127.255.255.255').ipclass).to eq(:a)
    expect(IPv4Addr.new('128.0.0.0').ipclass).to eq(:b)
    expect(IPv4Addr.new('172.16.0.0').ipclass).to eq(:b)
    expect(IPv4Addr.new('191.255.255.255').ipclass).to eq(:b)
    expect(IPv4Addr.new('192.0.0.0').ipclass).to eq(:c)
    expect(IPv4Addr.new('192.168.0.0').ipclass).to eq(:c)
    expect(IPv4Addr.new('223.255.255.255').ipclass).to eq(:c)
    expect(IPv4Addr.new('224.0.0.0').ipclass).to eq(:d)
    expect(IPv4Addr.new('224.1.2.3').ipclass).to eq(:d)
    expect(IPv4Addr.new('239.255.255.255').ipclass).to eq(:d)
    expect(IPv4Addr.new('240.0.0.0').ipclass).to eq(:e)
    expect(IPv4Addr.new('245.0.0.0').ipclass).to eq(:e)
    expect(IPv4Addr.new('255.255.255.255').ipclass).to eq(:e)
  end
end

describe :unicast? do
  it 'returns true if the address is unicast' do
    expect(IPv4Addr.new('0.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('10.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('127.255.255.255').unicast?).to eq(true)
    expect(IPv4Addr.new('128.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('172.16.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('191.255.255.255').unicast?).to eq(true)
    expect(IPv4Addr.new('192.0.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('192.168.0.0').unicast?).to eq(true)
    expect(IPv4Addr.new('223.255.255.255').unicast?).to eq(true)
  end

  it 'returns false if the address is not unicast' do
    expect(IPv4Addr.new('224.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('224.1.2.3').unicast?).to eq(false)
    expect(IPv4Addr.new('239.255.255.255').unicast?).to eq(false)
    expect(IPv4Addr.new('240.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('245.0.0.0').unicast?).to eq(false)
    expect(IPv4Addr.new('255.255.255.255').unicast?).to eq(false)
  end
end

describe :multicast? do
  it 'returns true if the address is multicast' do
    expect(IPv4Addr.new('224.0.0.0').multicast?).to eq(true)
    expect(IPv4Addr.new('224.1.2.3').multicast?).to eq(true)
    expect(IPv4Addr.new('239.255.255.255').multicast?).to eq(true)
  end

  it 'returns false if address is not multicast' do
    expect(IPv4Addr.new('0.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('10.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('127.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('128.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('172.16.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('191.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('192.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('192.168.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('223.255.255.255').multicast?).to eq(false)
    expect(IPv4Addr.new('240.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('245.0.0.0').multicast?).to eq(false)
    expect(IPv4Addr.new('255.255.255.255').multicast?).to eq(false)
  end
end

describe :to_s do
  it 'produces correct output for addresses starting with 0' do
    expect(IPv4Addr.new('0.0.0.0').to_s).to eq('0.0.0.0')
  end
end

describe :to_s_bracketed do
  it 'produces bracketed output' do
    expect(IPv4Addr.new('1.2.3.4').to_s_bracketed).to eq('[1.2.3.4]')
  end
end


# Parent-class methods

describe :included_in? do
  it 'calculates the correct values' do
    expect(IPv4Addr.new('1.2.3.4').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.0').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('255.255.255.255').included_in?(IPv4Net.new('0.0.0.0/0'))).to be_truthy
    expect(IPv4Addr.new('9.255.255.255').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_falsey
    expect(IPv4Addr.new('10.0.0.0').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_truthy
    expect(IPv4Addr.new('10.255.255.255').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_truthy
    expect(IPv4Addr.new('11.0.0.0').included_in?(IPv4Net.new('10.0.0.0/8'))).to be_falsey
  end
end

describe :succ do
  it 'returns a IPv4Addr' do
    expect(IPv4Addr.new('1.2.3.4').succ).to be_an_instance_of(IPv4Addr)
  end

  it 'return successive IP address by adding 1' do
    expect(IPv4Addr.new('1.2.3.4').succ).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('192.168.255.255').succ).to eq(IPv4Addr.new('192.169.0.0'))
  end
end

describe :next do
  it 'returns a IPv4Addr' do
    expect(IPv4Addr.new('1.2.3.4').next).to be_an_instance_of(IPv4Addr)
  end

  it 'return successive IP address by adding 1' do
    expect(IPv4Addr.new('1.2.3.4').next).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('192.168.255.255').next).to eq(IPv4Addr.new('192.169.0.0'))
  end
end

describe :== do
  it 'return true for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('1.2.3.4')).to be_truthy
    expect(IPv4Addr.new('0.0.0.0') == IPv4Addr.new('0.0.0.0')).to be_truthy
    expect(IPv4Addr.new('0.0.0.1') == IPv4Addr.new('0.0.0.1')).to be_truthy
    expect(IPv4Addr.new('255.255.255.255') == IPv4Addr.new('255.255.255.255')).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('0.0.0.0')).to be_falsey
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('255.255.255.255')).to be_falsey
    expect(IPv4Addr.new('1.2.3.4') == IPv4Addr.new('1.2.3.5')).to be_falsey
    expect(IPv4Addr.new('0.0.0.0') == IPv4Addr.new('255.255.255.255')).to be_falsey
    expect(IPv4Addr.new('255.255.255.255') == IPv4Addr.new('0.0.0.0')).to be_falsey
  end

  it 'return false for IPv6Addr' do
    expect(IPv4Addr.new('1.2.3.4') == IPv6Addr.new('2a09:62c0::1')).to be_falsey
  end

  it 'return false for IPv6 address string' do
    expect(IPv4Addr.new('1.2.3.4') == '2a09:62c0::1').to be_falsey
  end
end

describe :eql? do
  it 'return true for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('1.2.3.4'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.0').eql?(IPv4Addr.new('0.0.0.0'))).to be_truthy
    expect(IPv4Addr.new('0.0.0.1').eql?(IPv4Addr.new('0.0.0.1'))).to be_truthy
    expect(IPv4Addr.new('255.255.255.255').eql?(IPv4Addr.new('255.255.255.255'))).to be_truthy
  end

  it 'return false for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('0.0.0.0'))).to be_falsey
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('255.255.255.255'))).to be_falsey
    expect(IPv4Addr.new('1.2.3.4').eql?(IPv4Addr.new('1.2.3.5'))).to be_falsey
    expect(IPv4Addr.new('0.0.0.0').eql?(IPv4Addr.new('255.255.255.255'))).to be_falsey
    expect(IPv4Addr.new('255.255.255.255').eql?(IPv4Addr.new('0.0.0.0'))).to be_falsey
  end
end

describe '!=' do
  it 'returns true for different adddresses' do
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('255.255.255.255')).to be_truthy
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('1.2.3.5')).to be_truthy
    expect(IPv4Addr.new('0.0.0.0') != IPv4Addr.new('255.255.255.255')).to be_truthy
    expect(IPv4Addr.new('255.255.255.255') != IPv4Addr.new('0.0.0.0')).to be_truthy
  end

  it 'returns false for equal addresses' do
    expect(IPv4Addr.new('1.2.3.4') != IPv4Addr.new('1.2.3.4')).to be_falsey
    expect(IPv4Addr.new('0.0.0.0') != IPv4Addr.new('0.0.0.0')).to be_falsey
    expect(IPv4Addr.new('0.0.0.1') != IPv4Addr.new('0.0.0.1')).to be_falsey
    expect(IPv4Addr.new('255.255.255.255') != IPv4Addr.new('255.255.255.255')).to be_falsey
    expect((IPv4Addr.new('1.2.3.4') != IPv4Addr.new('0.0.0.0'))).to be_truthy
  end
end

describe :<=> do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.4')).to be_a_kind_of(Integer)
  end

  it 'compares correctly' do
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.4')).to eq(0)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.5')).to eq(-1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('1.2.3.3')).to eq(1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('0.0.0.0')).to eq(1)
    expect(IPv4Addr.new('1.2.3.4') <=> IPv4Addr.new('255.255.255.255')).to eq(-1)
  end
end

describe :+ do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new('1.2.3.4') + 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'sums correctly' do
    expect(IPv4Addr.new('1.2.3.4') + 1).to eq(IPv4Addr.new('1.2.3.5'))
    expect(IPv4Addr.new('1.2.3.4') + (-1)).to eq(IPv4Addr.new('1.2.3.3'))
    expect(IPv4Addr.new('1.2.3.4') + 10).to eq(IPv4Addr.new('1.2.3.14'))
  end
end

describe :- do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new('1.2.3.4') - 1)).to be_an_instance_of(IPv4Addr)
  end

  it 'subtracts Fixnum from address' do
    expect((IPv4Addr.new('1.2.3.4') - 1)).to eq(IPv4Addr.new('1.2.3.3'))
    expect((IPv4Addr.new('1.2.3.4') - (-1))).to eq(IPv4Addr.new('1.2.3.5'))
    expect((IPv4Addr.new('1.2.3.4') - 10)).to eq(IPv4Addr.new('1.2.2.250'))
  end

  it 'subtracts IPv4Addr from address' do
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.2')).to eq(2)
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.4')).to eq(0)
    expect(IPv4Addr.new('1.2.3.4') - IPv4Addr.new('1.2.3.6')).to eq(-2)
  end
end

describe :| do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x00000000) | 0x0000ffff)).to be_an_instance_of(IPv4Addr)
  end

  it 'operates correctly'do
    expect((IPv4Addr.new(0x00000000) | 0x0000ffff)).to eq(0x0000ffff)
  end
end

describe :& do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff)).to be_an_instance_of(IPv4Addr)
  end

  it 'operates correctly' do
    expect((IPv4Addr.new(0x0f0f0f0f) & 0x0000ffff)).to eq(0x00000f0f)
  end
end

describe :mask do
  it 'returns of type IPv4Addr' do
    expect((IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000))).to be_an_instance_of(IPv4Addr)
  end

  it 'masks correctly' do
    expect((IPv4Addr.new(0x0f0f0f0f).mask(0xffff0000))).to eq(0x0f0f0000)
  end
end

describe :to_i do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4').to_i).to be_a_kind_of(Integer)
  end

  it 'converts to integer' do
    expect(IPv4Addr.new(0x0f0f0f0f).to_i).to eq(0x0f0f0f0f)
  end
end

describe :hash do
  it 'returns a kind of Integer' do
    expect(IPv4Addr.new('1.2.3.4').hash).to be_a_kind_of(Integer)
  end

  it 'produces a hash' do
    expect(IPv4Addr.new(0x0f0f0f0f).to_i).to eq(0x0f0f0f0f)
  end
end

require 'json'
describe :to_json do
  it 'returns a representation for to_json' do
    expect(IPv4Addr.new('1.2.3.4').to_json).to eq('"1.2.3.4"')
  end
end

require 'yaml'
describe :to_json do
  it 'returns a representation for to_yaml' do
    expect(IPv4Addr.new('1.2.3.4').to_yaml).to eq("--- 1.2.3.4\n")
  end
end

describe :ipv4? do
  it 'returns true' do
    expect(IPv4Addr.new('1.2.3.4').ipv4?).to be_truthy
  end
end

describe :ipv6? do
  it 'returns false' do
    expect(IPv4Addr.new('1.2.3.4').ipv6?).to be_falsey
  end
end

end

end
