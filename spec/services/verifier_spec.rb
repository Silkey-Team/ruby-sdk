# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::Verifier, type: :controller do
  subject { described_class }

  let(:public_key) { build(:example).public_key }

  describe '.assert_required_params_for_scope' do
    describe 'expect NOT throw' do
      ['id', ['id'], ',id,', 'id,id'].each do |scope|
        it "scope=#{scope}" do
          expect { subject.require_params_for_scope(scope, { address: '1' }) }.not_to raise_error
        end
      end

      ['email', 'email,id', %w(email id), ',id,email,'].each do |scope|
        it "scope=#{scope}" do
          expect { subject.require_params_for_scope(scope, { address: '1', email: 'e' }) }.not_to raise_error
        end
      end
    end

    describe 'throws when' do
      it 'scope is empty' do
        expect { subject.require_params_for_scope('', {}) }.to raise_error(/scope is empty/)
      end

      it 'scope not supported' do
        expect { subject.require_params_for_scope('?', {}) }.to raise_error(/scope `\?` is not supported/)
      end

      it 'scope:id and missing address' do
        expect { subject.require_params_for_scope('id', {}) }
          .to raise_error(/`address` parameter is required for selected scope: id/)
      end

      it 'scope:email and missing address' do
        expect { subject.require_params_for_scope('email', {}) }
          .to raise_error(/`address` parameter is required for selected scope: email/)
      end

      it 'scope:email and missing address' do
        expect { subject.require_params_for_scope('email', { address: 'a' }) }
          .to raise_error(/`email` parameter is required for selected scope: email/)
      end

      it 'empty scope' do
        expect { subject.require_params_for_scope('', { address: 'a' }) }.to raise_error(/scope is empty/)
        expect { subject.require_params_for_scope([], { address: 'a' }) }.to raise_error(/scope is empty/)
      end
    end
  end

  describe '.website_signature_valid?' do
    let(:web_public_key) { build(:example).web_public_key }
    let(:callback_params_no_sign) { build(:callback_params_for_id, with_signature: false).params }
    let(:callback_params) { build(:callback_params_for_id).params }

    it 'expect to return false when website signature not exists' do
      expect(subject.website_signature_valid?(callback_params_no_sign, web_public_key)).to be_falsey
    end

    it 'expect to be true when sig match' do
      expect(subject.website_signature_valid?(callback_params, web_public_key)).to be_truthy
    end
  end

  describe '.user_signature_valid?' do
    let(:private_key) { build(:example).private_key }

    it 'expect to return false when user signature not exists' do
      expect(subject.user_signature_valid?({})).to be_falsey
    end

    it 'expect to return false when user signature NOT valid' do
      payload = {
        address: '0xeC147F4bdEF4d1690A98822940548713f91567E4',
        userSignature: '0x24a1a2156e3bb590f683bdb2ac35e9c0d66006b7d7424229577b2e74e1905ca71fbd10227299e170dba55abc060' \
                       '74001e5cade5dfe68b3e5f5d914106f1d750f1b'
      }
      expect(subject.user_signature_valid?(payload)).to be_falsey
    end

    it 'expect to return false when address not set' do
      payload = {
        address: '',
        userSignature: '0x24a1a2156e3bb590f683bdb2ac35e9c0d66006b7d7424229577b2e74e1905ca71fbd10227299e170dba55abc060' \
                       '74001e5cade5dfe68b3e5f5d914106f1d750f1b'
      }

      expect(subject.user_signature_valid?(payload)).to be_falsey
    end

    it 'expect to return FALSE when user signature timestamp invalid' do
      payload = Silkey::Models::JwtPayload.new.import({
                                                        address: public_key,
                                                        scope: 'id',
                                                        userSignatureTimestamp: 123
                                                      })
      signature = Silkey::Utils.sign_message(private_key, payload.message_to_sign_by_user)
      payload.set_user_signature(signature, 122)

      expect(subject.user_signature_valid?(payload)).to be_falsey
    end

    it 'expect to return TRUE when user signature valid' do
      payload = Silkey::Models::JwtPayload.new.import({
                                                        address: public_key,
                                                        email: 'a@c',
                                                        scope: 'email',
                                                        user_signature_timestamp: 123
                                                      })

      signature = Silkey::Utils.sign_message(private_key, payload.message_to_sign_by_user)
      payload.set_user_signature(signature, payload.user_signature_timestamp)

      expect(subject.user_signature_valid?(payload)).to be_truthy
    end
  end

  describe '.silkey_signature_valid?' do
    it 'expect to return null when email and sig empty' do
      expect(subject.silkey_signature_valid?({})).to be_nil
    end

    it 'expect to return FALSE when email xor silkeySignature empty' do
      expect(subject.silkey_signature_valid?({ email: 'a' })).to be_falsey
      expect(subject.silkey_signature_valid?({ silkeySignature: 'a' })).to be_falsey
      expect(subject.silkey_signature_valid?({ silkeySignature: 'a', email: 'a' })).to be_falsey
    end

    it 'expect to return TRUE' do
      payload = {
        email: 'aliasId@privaterelay',
        silkeySignature: '0x228b203190b5c1f764e3a5a830bf40702fa1ebed3ce67734a38fb40b8da99ce97218238371ca93f3c850134'\
              '8b520b1a5399f4cf39995ccbcd48b4fffe48aa7ca1b',
        silkeySignatureTimestamp: 1_605_290_733
      }

      expect(subject.silkey_signature_valid?(payload)).to be_truthy
      expect(subject.silkey_signature_valid?(payload, public_key)).to be_truthy
    end

    it 'expect to return FALSE if public key do not match' do
      addr = "0x#{['1'].cycle(40).to_a.join('')}"

      payload = {
        email: 'aliasId@privaterelay',
        silkeySignature: '0x228b203190b5c1f764e3a5a830bf40702fa1ebed3ce67734a38fb40b8da99ce9721'\
'8238371ca93f3c8501348b520b1a5399f4cf39995ccbcd48b4fffe48aa7ca1b',
        silkeySignatureTimestamp: 1_605_290_733
      }

      expect(subject.silkey_signature_valid?(payload, addr)).to be_falsey
    end
  end
end
