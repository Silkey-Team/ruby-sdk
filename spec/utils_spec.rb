# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::Utils do
  subject { Silkey::Utils }

  private_key = '0x2c06e0037dacc4a831049ce0770f5f6f788827659a5842ed96d34c0631d5f6de'
  public_key = '0xDBF03b99664deb3C73045ac8933A6db89fefFf5F'

  describe 'empty?' do
    it 'returns true' do
      expect(subject.empty?('')).to eq(true)
      expect(subject.empty?(nil)).to eq(true)
    end

    it 'returns false' do
      expect(subject.empty?('a')).to eq(false)
      expect(subject.empty?({})).to eq(false)
    end
  end

  describe 'remove0x' do
    it 'returns string without 0x' do
      a = '0x123'
      subject.remove0x(a)
      expect(a).to eq('0x123')
      expect(subject.remove0x(a)).to eq('123')
    end
  end

  describe 'add0x' do
    it 'returns string with 0x' do
      expect(subject.add0x('123')).to eq('0x123')
      expect(subject.add0x('0x123')).to eq('0x123')
    end
  end

  describe 'hex?' do
    it 'checks if string is a hex' do
      expect(subject.hex?('')).to eq(false)
      expect(subject.hex?(nil)).to eq(false)
      expect(subject.hex?('xyz')).to eq(false)

      expect(subject.hex?('123')).to eq(true)
      expect(subject.hex?('0x123')).to eq(true)
    end
  end

  describe 'zero_hex?' do
    it 'checks if string is a hex' do
      expect(subject.empty_hex?('x')).to eq(false)
      expect(subject.empty_hex?('0x123')).to eq(false)

      expect(subject.empty_hex?(nil)).to eq(true)
      expect(subject.empty_hex?('')).to eq(true)
      expect(subject.empty_hex?('0000')).to eq(true)
      expect(subject.empty_hex?('0x000')).to eq(true)
    end
  end

  describe 'private_key?' do
    it 'checks if string is a private_key' do
      expect(subject.private_key?('')).to eq(false)
      expect(subject.private_key?(nil)).to eq(false)
      expect(subject.private_key?('xyz')).to eq(false)
      expect(subject.private_key?('0x123')).to eq(false)
      expect(subject.private_key?(['x'].cycle(64).to_a.join(''))).to eq(false)
      expect(subject.private_key?(['1'].cycle(65).to_a.join(''))).to eq(false)
      expect(subject.private_key?("0x#{['0'].cycle(64).to_a.join('')}")).to eq(false)
      expect(subject.private_key?(['0'].cycle(64).to_a.join(''))).to eq(false)

      expect(subject.private_key?("0x#{['1'].cycle(64).to_a.join('')}")).to eq(true)
      expect(subject.private_key?(['1'].cycle(64).to_a.join(''))).to eq(true)
    end
  end

  describe 'ethereum_address?' do
    it 'checks if string is a ethereum_address' do
      expect(subject.ethereum_address?('')).to eq(false)
      expect(subject.ethereum_address?(nil)).to eq(false)
      expect(subject.ethereum_address?('x')).to eq(false)
      expect(subject.ethereum_address?(['x'].cycle(40).to_a.join(''))).to eq(false)
      expect(subject.ethereum_address?(['1'].cycle(41).to_a.join(''))).to eq(false)
      expect(subject.ethereum_address?(['0'].cycle(40).to_a.join(''))).to eq(false)
      expect(subject.ethereum_address?("0x#{['0'].cycle(40).to_a.join('')}")).to eq(false)

      expect(subject.ethereum_address?(['1'].cycle(40).to_a.join(''))).to eq(true)
      expect(subject.ethereum_address?("0x#{['1'].cycle(40).to_a.join('')}")).to eq(true)
    end
  end

  describe 'signature?' do
    it 'checks if string is a ethereum_address' do
      expect(subject.signature?('')).to eq(false)
      expect(subject.signature?(nil)).to eq(false)
      expect(subject.signature?('x')).to eq(false)
      expect(subject.signature?(['x'].cycle(130).to_a.join(''))).to eq(false)
      expect(subject.signature?(['1'].cycle(131).to_a.join(''))).to eq(false)
      expect(subject.signature?(['0'].cycle(130).to_a.join(''))).to eq(false)
      expect(subject.signature?("0x#{['0'].cycle(130).to_a.join('')}")).to eq(false)

      expect(subject.signature?(['1'].cycle(130).to_a.join(''))).to eq(true)
      expect(subject.signature?("0x#{['1'].cycle(130).to_a.join('')}")).to eq(true)
    end
  end

  describe 'str_to_bytes32' do
    it 'transform string to bytes32' do
      expect(subject.str_to_bytes32('')).to eq('')
      expect(subject.str_to_bytes32(nil)).to eq('')
      expect(subject.str_to_bytes32(0))
        .to eq('0x3000000000000000000000000000000000000000000000000000000000000000')

      expect(subject.str_to_bytes32('0'))
        .to eq('0x3000000000000000000000000000000000000000000000000000000000000000')

      expect(subject.str_to_bytes32('Zeus'))
        .to eq('0x5a65757300000000000000000000000000000000000000000000000000000000')
    end
  end

  describe 'int_to_hex - must be align with NodeJS SDK' do
    it { expect(subject.int_to_hex(1)).to eq('01') }
    it { expect(subject.int_to_hex(16)).to eq('10') }
    it { expect(subject.int_to_hex(31)).to eq('1f') }
    it { expect(subject.int_to_hex(256)).to eq('0100') }
    it { expect(subject.int_to_hex(1_604_499_020)).to eq('5fa2b64c') }
    it { expect(subject.int_to_hex('1604499020')).to eq('5fa2b64c') }
  end

  describe 'strings_to_hex - must be align with NodeJS SDK' do
    it { expect(subject.strings_to_hex([''])).to eq('') }
    it { expect(subject.strings_to_hex(%w(1))).to eq('31') }
    it { expect(subject.strings_to_hex(%w(1 2))).to eq('3132') }
    it { expect(subject.strings_to_hex(['', '1'])).to eq('31') }

    it do
      expect(subject.strings_to_hex(%w(żźćłóęąń 0))).to eq('c5bcc5bac487c582c3b3c499c485c58430')
    end
  end

  describe 'sign/recover message' do
    message = 'abc'

    it do
      signature = subject.sign_plain_message(private_key, message)
      expect(subject.verify_plain_message(message, signature)).to eq(public_key)
    end

    it do
      signature_from_nodejs = '0x79dff71e50e62de7c76314f08014229694e50c31dc099a1c86d60f6c7de1f7b'\
                              '663b086b36e3168b676f6bd56f3ac4402748a37328cf04917b61fad9f9f016ff11b'
      expect(subject.verify_message(message, signature_from_nodejs)).to eq(public_key)
    end

    it do
      signature = subject.sign_message(private_key, message)
      expect(subject.verify_message(message, signature)).to eq(public_key)
    end
  end
end
