# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::SDK, type: :service do
  subject { described_class }

  addr = "0x#{['1'].cycle(40).to_a.join('')}"
  sig = "0x#{['2'].cycle(130).to_a.join('')}"

  private_key = '0x2c06e0037dacc4a831049ce0770f5f6f788827659a5842ed96d34c0631d5f6de'
  public_key = '0xDBF03b99664deb3C73045ac8933A6db89fefFf5F'

  valid_scope_id_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6ImlkIiwiYWRkcmVzcyI6Ij'\
'B4MTQwQzRCZjUzNDJjOWIwMTFCOTMyNEQ0OTEyRmM2OTQzMjcwNTJGNSIsInJlZklkIjoiIiwic2lsa2V5U2lnbmF0dXJlIj'\
'oiIiwic2lsa2V5U2lnbmF0dXJlVGltZXN0YW1wIjoiIiwidXNlclNpZ25hdHVyZSI6IjB4OTVlYjBmOTNjNzQ1MmMxZmEwNj'\
'VjNzdhNDc1MzJjZTViMTY5MDY1NDNjYTM2YmYwOTlmNmY5YTk2ZDAxNWMxNjM5OGE5ZmY3YjEwMzQ4YzhmNjgzYWZjMGQ3Nz'\
'FkYTFiZWQ5MTE5ZjkyN2YxMmU3ZmNjYThiZmZhMzEyNmI3ZTYxYiIsInVzZXJTaWduYXR1cmVUaW1lc3RhbXAiOjE2MDUzNT'\
'MxMTUsImlhdCI6MTYwNTM1MzExNX0.sFQOjylV5FcxaOKC7mrmJWSbdQNEt87-tf1LwEFiIp4'
  valid_scope_email_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6ImVtYWlsIiwiYWRkcmV'\
'zcyI6IjB4Nzg4NzRGNjE3Y2JCMTNjZDNmM2JEZTljNDk5MDBCNDRkYzk3NDNFNSIsInJlZklkIjoiIiwic2lsa2V5U2lnbmF'\
'0dXJlIjoiMHg5NDQ3ZmMxZTIzNWFhOWEyMTY1ZTlkNjgxMDMxYzE2NzFmZmYyYTBkYjJhMGVhODIwNzQ0NjcwMTk2ZTU3YzU'\
'3NWNlNWU3MDI2ODBlODE4ZjUxMDQzYjFmNzBiMzM1MTBkYzU5OWM4YmI1NTUzODNlOTI5NGEyZWY4ZWMyMzQzYzFiIiwic2l'\
'sa2V5U2lnbmF0dXJlVGltZXN0YW1wIjoxNjA1MzUzMTE1LCJ1c2VyU2lnbmF0dXJlIjoiMHhkOTc1YTg2MWExNDUxYWJhOWI'\
'2NWYxMzE1Mjg2NWU5YTYyM2E2ZGIyN2ZmNmM3MzI5ZjY3YjI5MWU5MzMwZTY4NzlmNWQ5MDcwOGU2MDI5NDgyNWY1MjM2ODI'\
'xYjJhNDUzMTY3ZTBmZjFiYjJmN2E2MTQ4NjFhZmZjZjlkOTE1MzFjIiwidXNlclNpZ25hdHVyZVRpbWVzdGFtcCI6MTYwNTM'\
'1MzExNSwiZW1haWwiOiJhbGlhc0lkQHByaXZhdGVyZWxheSIsImlhdCI6MTYwNTM1MzExNX0.BUB5dSxh4ZxfYcaI8bW6xAg'\
'w6Xfq5xP8KZSRCOsDlHo'
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
      params = subject.generate_sso_request_params(private_key, { :sigTimestamp => 1_602_151_787 })
      expect(params[:sigTimestamp]).to eq(1_602_151_787)
    end

    it 'sets timestamp when not provided' do
      params = subject.generate_sso_request_params(private_key, {})
      expect(params[:sigTimestamp]).to be > 1_602_151_787
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
