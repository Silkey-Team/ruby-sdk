# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::SDK, type: :service do
  subject { described_class }

  # addr = "0x#{['1'].cycle(40).to_a.join('')}"
  # sig = "0x#{['2'].cycle(130).to_a.join('')}"

  private_key = '0x2c06e0037dacc4a831049ce0770f5f6f788827659a5842ed96d34c0631d5f6de'
  public_key = '0xDBF03b99664deb3C73045ac8933A6db89fefFf5F'

  valid_scope_id_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6ImlkIiwiYWRkcmVzcyI6Ij'\
'B4OTJiQzNENzc2MTkyZDkyZmIxY0ZiZjQ1MzA5RmY1MWRGMkNCNTUyNSIsInJlZklkIjoiIiwic2lsa2V5U2lnbmF0dXJlIj'\
'oiIiwic2lsa2V5U2lnbmF0dXJlVGltZXN0YW1wIjoiIiwidXNlclNpZ25hdHVyZSI6IjB4ZDAxZjc4ZDNjNmJiZGExNGYyMT'\
'Y4OWQxZGI1Y2IyNzY4NDVmOWM5YmE4ZTQwZmViYjBmMTAzYWViM2MzYTRmNzA3NGU4OWQ3YTlmYTc2MzgxOTk3YTlmNDlmZG'\
'ZjMWE3ODVhNDRhNjY5OGYxNDMzZWE3ZDc0NmE0NTIwM2Y3ZWMxYyIsInVzZXJTaWduYXR1cmVUaW1lc3RhbXAiOjE2MDU1ND'\
'g1ODYsImlhdCI6MTYwNTU0ODU4NX0.MWCyGF5AA0wQU-isKqVOZNkHX7modz14xoNzQB-ieNM'

  valid_scope_email_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6ImVtYWlsIiwiYWRkcmV'\
'zcyI6IjB4YTQxQTlEMDhlMTg1M0FlYWUzOTVCNGU4OTFDOTg2MTgzOEJFNkI0YyIsInJlZklkIjoiIiwic2lsa2V5U2lnbmF'\
'0dXJlIjoiMHg0MzEzYzNjZDkwZGRlMzNiM2VmMTI5YTk3ZjNhMDExNmIyZjUyOTBlYTgyYTM2MmEyNjdiNmUyZGJjMjBlNDE'\
'0NjliMGI4YzU4YjRjMWQzZmE5MTc4YjZjMTFhNjEyODZhMjBhNjAyNDRhOGQ5NGM4ODNmNzJkNzY0NDZiMzVlNDFjIiwic2l'\
'sa2V5U2lnbmF0dXJlVGltZXN0YW1wIjoxNjA1NTQ4NTg2LCJ1c2VyU2lnbmF0dXJlIjoiMHhmNGUwODU2NjFmYThmNTliYWE'\
'0OTFlYjI3N2ViMWRlZGNjODVkY2NlNGE0MWIxYzM1YzVmNmU0YWNlZjdkZGZhMzYwZTk5NjMxOThkNmFiNzI2N2ZhMmE1MmV'\
'hMGQzYWZiN2MwNTE3YTMxZjhlMGVmYmJjZDYzNWU0NmU3ZDRhOTFiIiwidXNlclNpZ25hdHVyZVRpbWVzdGFtcCI6MTYwNTU'\
'0ODU4NiwiZW1haWwiOiJhbGlhc0lkQHByaXZhdGVyZWxheSIsImlhdCI6MTYwNTU0ODU4NX0.3rc0CpSIZEMMprKNO-sA2bM'\
'0tnHBSFcM2TF61i_2854'

  invalid_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IjB4NjNmNUY0YjUzNjE3MTBiYzViM'\
'ThBZTYyZGJjQzRkRTFiNjY0RjlCNEBwcml2YXRlcmVsYXkuc2lsa2V5LmlvIiwiYWRkcmVzcyI6IjB4RTIxNDA3ZDc4Q0FkQ'\
'zQzNDczNTZGMjhiM0U2Mjc1NDM5MzM5RDA4NCIsInNpZ25hdHVyZSI6eyJyIjoiMHgyNmUxZGM0MzA4ZTViMDRiNGVhZWVlN'\
'zI0MWYwMjgzOTM0ZTgzYmE1OTMzYjM5NThkOTIyYmRiNmRkOTgzOTc3IiwicyI6IjB4MmMyOGQ2YmZmZWMxYThjOTFlNDFlO'\
'DJjMWJjMzBmYzZkMTNjYzljNDk1Y2ZhNzQ3MjUzNzQ4OTVlMzhiZTdmNSIsIl92cyI6IjB4YWMyOGQ2YmZmZWMxYThjOTFlN'\
'DFlODJjMWJjMzBmYzZkMTNjYzljNDk1Y2ZhNzQ3MjUzNzQ4OTVlMzhiZTdmNSIsInJlY292ZXJ5UGFyYW0iOjEsInYiOjI4f'\
'SwiaWF0IjoxNjAyMTQ1MzU2fQ.kmmHfO7mGpHsoZoRcAis373rwNDyyzj3rT0-nbiJmN4'

  describe '.message_to_sign' do
    it { expect(subject.message_to_sign({})).to eq('') }
    it { expect(subject.message_to_sign({ b: '2', a: '1' })).to eq('a=1&b=2') }
    it { expect(subject.message_to_sign({ c: '', d: nil, b: '2', a: '1' })).to eq('a=1&b=2&c=') }
    it { expect(subject.message_to_sign({ c: '', d: '', b: '2', a: '1' })).to eq('a=1&b=2&c=&d=') }

    describe 'when hashed' do
      it 'expect to generate same hash' do
        message1 = subject.message_to_sign({ c: '', d: nil, b: '2', a: '1' })
        message2 = subject.message_to_sign({ c: '', b: '2', a: '1' })

        hash1 = Eth::Utils.keccak256(message1)
        hash2 = Eth::Utils.keccak256(message2)

        expect(hash1).to eq(hash2)
      end
    end
  end

  describe '.generate_sso_request_params' do
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
          .to raise_error(/`redirectUrl` is empty/)

        expect { subject.generate_sso_request_params(private_key, { redirectUrl: '1' }) }
          .to raise_error(/`cancelUrl` is empty/)
      end
    end

    it 'expect to use `ssoTimestamp` when not empty' do
      params = subject.generate_sso_request_params(
        private_key,
        { ssoTimestamp: 1_602_151_787, redirectUrl: 'http', cancelUrl: 'http' }
      )

      expect(params[:ssoTimestamp]).to eq(1_602_151_787)
    end

    it 'sets timestamp when not provided' do
      params = subject.generate_sso_request_params(
        private_key, { redirectUrl: 'http', cancelUrl: 'http' }
      )

      expect(params[:ssoTimestamp]).to be > 1_602_151_787
    end

    it 'expect to generate signature and ignore not set values' do
      data = { redirectUrl: 'http', cancelUrl: 'http', ssoTimestamp: 1_602_151_787 }
      message = 'cancelUrl=http&redirectUrl=http&scope=id&ssoTimestamp=1602151787'

      params = subject.generate_sso_request_params(private_key, data)
      expect(Silkey::Utils.verify_message(message, params[:signature])).to eq(public_key)

      data[:unset] = nil
      params_unset = subject.generate_sso_request_params(private_key, data)
      expect(Silkey::Utils.verify_message(message, params_unset[:signature])).to eq(public_key)

      data[:unset] = ''
      params_set = subject.generate_sso_request_params(private_key, data)
      expect(Silkey::Utils.verify_message(message, params_set[:signature])).to_not eq(public_key)
    end
  end

  describe '.token_payload_verifier' do
    describe 'without silkey public key' do
      it { expect(subject.token_payload_verifier(valid_scope_id_token)).to be_truthy }
      it { expect(subject.token_payload_verifier(valid_scope_email_token)).to be_truthy }
      it { expect(subject.token_payload_verifier(invalid_token)).to be_nil }
    end
  end
end
