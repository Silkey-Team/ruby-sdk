# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::SDK, type: :service do
  subject { described_class }

  addr = "0x#{['1'].cycle(40).to_a.join('')}"
  sig = "0x#{['2'].cycle(130).to_a.join('')}"

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

  describe 'message_to_sign' do
    it { expect(subject.message_to_sign({})).to eq('') }
    it { expect(subject.message_to_sign({ b: '2', a: '1' })).to eq('a=1::b=2') }
  end

  describe 'generate_sso_request_params' do
    it do
      params = subject.generate_sso_request_params(private_key, { :ssoTimestamp => 1_602_151_787 })
      expect(params[:ssoTimestamp]).to eq(1_602_151_787)
    end

    it 'sets timestamp when not provided' do
      params = subject.generate_sso_request_params(private_key, {})
      expect(params[:ssoTimestamp]).to be > 1_602_151_787
    end
  end

  describe 'token_payload_verifier' do
    describe 'without silkey public key' do
      it { expect(subject.token_payload_verifier(valid_scope_id_token)).to be_truthy }
      it { expect(subject.token_payload_verifier(valid_scope_email_token)).to be_truthy }
      it { expect(subject.token_payload_verifier(invalid_token)).to be_nil }
    end
  end
end
