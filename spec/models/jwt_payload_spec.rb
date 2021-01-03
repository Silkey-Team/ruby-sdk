# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::Models::JwtPayload, type: :model do
  subject { described_class.new.attributes }

  it {  is_expected.to include(:address) }
  it {  is_expected.to include(:email) }
  it {  is_expected.to include(:silkey_signature) }
  it {  is_expected.to include(:silkey_signature_timestamp) }
  it {  is_expected.to include(:user_signature) }
  it {  is_expected.to include(:user_signature_timestamp) }
end

RSpec.describe Silkey::Models::JwtPayload, type: :model do
  subject { described_class.new }
  addr = "0x#{['1'].cycle(40).to_a.join('')}"
  sig = "0x#{['2'].cycle(130).to_a.join('')}"

  describe 'scope' do
    it { expect { subject._scope }.to raise_error(NoMethodError) }

    it 'sets scope' do
      subject.set_scope('id')
      expect(subject.scope).to eq('id')
    end

    it 'get_scope returns sorted values' do
      subject
        .set_scope('email')
        .set_scope('b')
        .set_scope('a')

      expect(subject.scope).to eq('a,b,email')
    end
  end

  describe 'setters' do
    it { expect { subject.set_address('id') }.to raise_error(/`id` is not ethereum address/) }

    it 'sets address' do
      subject.set_address(addr)
      expect(subject.address).to eq(addr)
    end

    it 'sets user signature' do
      subject.set_user_signature(sig, 1)
      expect(subject.user_signature).to eq(sig)
      expect(subject.user_signature_timestamp).to eq(1)
    end

    it 'sets silkey signature' do
      subject.set_silkey_signature(sig, 1)
      expect(subject.silkey_signature).to eq(sig)
      expect(subject.silkey_signature_timestamp).to eq(1)
    end
  end

  describe 'message_to_sign_by_user' do
    it 'expect to have message for empty values' do
      expect(subject.message_to_sign_by_user)
        .to eq('616464726573736d6967726174696f6e0073636f7065757365725369676e617475726554696d657374616d7000')
    end

    it 'expect to have valid message when values are set' do
      subject
        .set_email('a@b.c')
        .set_scope('email')
        .set_address(addr)
        .set_user_signature(sig, 1_234_567_890)

      expect(subject.message_to_sign_by_user)
        .to eq('616464726573731111111111111111111111111111111111111111'\
               '6d6967726174696f6e0073636f7065656d61696c75736572536967'\
               '6e617475726554696d657374616d70499602d2')
    end

    describe 'validate' do
      it 'raise error when missing data, scope ID' do
        expect { subject.validate }.to raise_error(/address is invalid: /)
        subject.set_scope('id')
        expect { subject.validate }.to raise_error(/address is invalid: /)
        subject.set_address(addr)
        expect { subject.validate }.to raise_error(/user_signature is invalid: /)
        subject.set_user_signature(sig, 1_607_790_167)

        expect { subject.validate }.to_not raise_error
      end

      it 'raise error when missing data, scope EMAIL' do
        subject.set_scope('email')
        subject.set_address(addr)
        subject.set_user_signature(sig, 1_607_790_167)

        expect { subject.validate }.to raise_error(/email is empty/)
        subject.set_email('e@m')
        expect { subject.validate }.to raise_error(/silkey_signature is invalid: /)
        subject.set_silkey_signature(sig, 1_607_790_167)

        expect { subject.validate }.to_not raise_error
      end
    end
  end

  describe 'import' do
    it 'expect to import data from hash to object (arrow object)' do
      payload = { 'scope' => 'id',
                  'silkeySignature' => nil,
                  'silkeySignatureTimestamp' => nil,
                  'userSignature' => '0xc9d8287da2304225cf1040a72055cbdec21709b70b30e384d6e4b13422'\
                                     'ee219178403342828a850dc449782c935ca1bc7033fd89c313202868b293'\
                                     '9b2d05430f1c',
                  'userSignatureTimestamp' => 1_604_688_865,
                  'address' => '0xcfA6bED7B5681CFa3AdF53bF31eB3cd06993cADe',
                  'iat' => 1_604_688_865 }

      imported = described_class.new.import(payload)

      expect(imported).to be_instance_of(Silkey::Models::JwtPayload)

      expect(imported.scope).to eq(payload['scope'])
      expect(imported.address).to eq(payload['address'])
      expect(imported.email).to eq(payload['email'])
      expect(imported.silkey_signature).to eq(payload['silkeySignature'])
      expect(imported.silkey_signature_timestamp).to eq(payload['silkeySignatureTimestamp'])
      expect(imported.user_signature).to eq(payload['userSignature'])
      expect(imported.user_signature_timestamp).to eq(payload['userSignatureTimestamp'])
    end

    it 'expect to import data from hash to object' do
      payload = { scope: 'id',
                  silkeySignature: nil,
                  silkeySignatureTimestamp: nil,
                  userSignature: '0xc9d8287da2304225cf1040a72055cbdec21709b70b30e384d6e4b13422'\
                                 'ee219178403342828a850dc449782c935ca1bc7033fd89c313202868b293'\
                                 '9b2d05430f1c',
                  userSignatureTimestamp: 1_604_688_865,
                  address: '0xcfA6bED7B5681CFa3AdF53bF31eB3cd06993cADe',
                  iat: 1_604_688_865 }

      imported = described_class.new.import(payload)

      expect(imported).to be_instance_of(Silkey::Models::JwtPayload)

      expect(imported.scope).to eq(payload[:scope])
      expect(imported.address).to eq(payload[:address])
      expect(imported.email).to eq(payload[:email])
      expect(imported.silkey_signature).to eq(payload[:silkeySignature])
      expect(imported.silkey_signature_timestamp).to eq(payload[:silkeySignatureTimestamp])
      expect(imported.user_signature).to eq(payload[:userSignature])
      expect(imported.user_signature_timestamp).to eq(payload[:userSignatureTimestamp])
    end

    it 'get_scope returns sorted values' do
      subject
        .set_scope('email')
        .set_scope('b')
        .set_scope('a')

      expect(subject.scope).to eq('a,b,email')
    end
  end
end
