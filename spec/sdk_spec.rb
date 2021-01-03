# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::SDK, type: :service do
  subject { described_class }

  let(:web_public_key) { build(:example).web_public_key }
  let(:web_private_key) { build(:example).web_private_key }

  describe '.message_to_sign' do
    it { expect(subject.message_to_sign({})).to eq('') }
    it { expect(subject.message_to_sign({ b: '2', a: '1' })).to eq('') }

    it do
      expect(subject.message_to_sign({ ssoTimestamp: '', ssoScope: 'id', ssoRefId: '2' }))
        .to eq('ssoRefId=2::ssoScope=id::ssoTimestamp=')
    end

    it 'generates empty message for data that are NOT prefixed with SSO prefix' do
      expect(subject.message_to_sign({ d: nil, c: '', b: 2, a: 1 })).to eq('')
    end

    it 'generates message with sorted data' do
      expect(subject.message_to_sign({ ssoD: nil, ssoC: 'c', sso: 2, ssoA: 1 }))
        .to eq("sso=2#{Silkey::Settings.MESSAGE_TO_SIGN_GLUE}ssoA=1#{Silkey::Settings.MESSAGE_TO_SIGN_GLUE}ssoC=c")
    end

    it 'exclude ssoSignature' do
      expect(subject.message_to_sign({ ssoSignature: nil, ssoC: 'c' })).to eq('ssoC=c')
    end

    describe 'when message hashed' do
      it 'expect to generate same hash' do
        message1 = subject.message_to_sign({ ssoTimestamp: '', ssoScope: 'id', ssoRefId: '2' })
        message2 = subject.message_to_sign({ ssoTimestamp: '', ssoScope: 'id', ssoRefId: '2', ssoRedirectMethod: nil })

        hash1 = Eth::Utils.keccak256(message1)
        hash2 = Eth::Utils.keccak256(message2)

        expect(hash1).to eq(hash2)
      end
    end
  end

  describe '.generate_sso_request_params' do
    let(:private_key) { build(:example).private_key }

    describe 'raise error when' do
      it 'PK is empty or invalid' do
        expect { subject.generate_sso_request_params(nil, nil) }
          .to raise_error(/`private_key` is empty/)

        expect { subject.generate_sso_request_params('', nil) }
          .to raise_error(/`private_key` is empty/)

        expect { subject.generate_sso_request_params(0x123, nil) }.to raise_error(NameError)
      end

      it 'missing required params' do
        expect { subject.generate_sso_request_params(private_key, nil) }.to raise_error(NameError)

        expect { subject.generate_sso_request_params(private_key, {}) }
          .to raise_error(/Missing required params/)

        expect { subject.generate_sso_request_params(private_key, { ssoRedirectUrl: '1' }) }
          .to raise_error(/Missing required params/)

        expect { subject.generate_sso_request_params(private_key, { ssoRedirectUrl: '1', ssoCancelUrl: '1' }) }
          .not_to raise_error
      end
    end

    it 'expect to use `ssoTimestamp` when not empty' do
      params = subject.generate_sso_request_params(
        private_key,
        { ssoTimestamp: 1_602_151_787, ssoRedirectUrl: 'http', ssoCancelUrl: 'http' }
      )

      expect(params[:ssoTimestamp]).to eq(1_602_151_787)
    end

    it 'sets timestamp when not provided' do
      params = subject.generate_sso_request_params(
        web_private_key, { ssoRedirectUrl: 'http', ssoCancelUrl: 'http' }
      )

      expect(params[:ssoTimestamp]).to be > 1_602_151_787
    end

    it 'expect to generate signature and ignore not set values' do
      data = { ssoRedirectUrl: 'http', ssoCancelUrl: 'http', ssoTimestamp: 1_602_151_787 }
      message = "ssoCancelUrl=http#{Silkey::Settings.MESSAGE_TO_SIGN_GLUE}ssoRedirectUrl=http"\
                "#{Silkey::Settings.MESSAGE_TO_SIGN_GLUE}ssoTimestamp=1602151787"

      params = subject.generate_sso_request_params(web_private_key, data)
      expect(Silkey::Utils.verify_message(message, params[:ssoSignature])).to eq(web_public_key)

      data[:unset] = nil
      params_unset = subject.generate_sso_request_params(web_private_key, data)
      expect(Silkey::Utils.verify_message(message, params_unset[:ssoSignature])).to eq(web_public_key)
    end
  end

  describe '.token_payload_verifier' do
    let(:scope_id_token) { build(:example).valid_scope_id_token }
    let(:scope_email_token) { build(:example).valid_scope_email_token }
    let(:invalid_token) { build(:example).invalid_token }
    let(:callback_params_for_id) { build(:callback_params_for_id).params }
    let(:callback_params_for_email) { build(:callback_params_for_email).params }
    let(:silkey_public_key) { build(:example).public_key }

    it 'validates token for scope ID and returns payload' do
      payload = subject.token_payload_verifier(
        scope_id_token, callback_params_for_id, web_public_key, silkey_public_key, 0
      )

      expect(payload).not_to be_nil
      expect(payload.address).not_to be_nil
    end

    it 'validates token for scope ID and returns payload (wo silkey key)' do
      payload = subject.token_payload_verifier(scope_id_token, callback_params_for_id, web_public_key, nil, 0)
      expect(payload).not_to be_nil
      expect(payload.address).not_to be_nil
    end

    it 'validates token for scope:email and returns payload' do
      payload = subject.token_payload_verifier(
        scope_email_token, callback_params_for_email, web_public_key, silkey_public_key, 0
      )

      expect(payload).not_to be_nil

      expect(payload.address).not_to be_nil
      expect(payload.email).not_to be_nil
      expect(payload.silkey_signature).not_to be_nil
      expect(payload.silkey_signature_timestamp).not_to be_nil
    end

    it 'validates token for scope:email and returns payload (wo silkey key)' do
      payload = subject.token_payload_verifier(scope_email_token, callback_params_for_email, web_public_key, nil, 0)
      expect(payload).not_to be_nil

      expect(payload.address).not_to be_nil
      expect(payload.email).not_to be_nil
      expect(payload.silkey_signature).not_to be_nil
      expect(payload.silkey_signature_timestamp).not_to be_nil
    end

    it 'returns null when token is old' do
      payload = subject.token_payload_verifier(invalid_token, {}, web_public_key)
      expect(payload).to be_nil
    end

    it 'returns null when token invalid' do
      payload = subject.token_payload_verifier(invalid_token, {}, web_public_key, silkey_public_key, 0)
      expect(payload).to be_nil
    end
  end
end
