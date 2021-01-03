# frozen_string_literal: true

class ExampleData
  attr_accessor :public_key
  attr_accessor :private_key
  attr_accessor :web_public_key
  attr_accessor :web_private_key
  attr_accessor :valid_scope_id_token
  attr_accessor :valid_scope_email_token
  attr_accessor :invalid_token
end

# rubocop:disable Layout/LineLength
FactoryBot.define do
  factory :example, class: ExampleData do
    public_key { '0xDBF03b99664deb3C73045ac8933A6db89fefFf5F' }
    private_key { '0x2c06e0037dacc4a831049ce0770f5f6f788827659a5842ed96d34c0631d5f6de' }
    web_public_key { '0x1dca9FEB4F78C2E693cd87B01824428338d0F4E9' }
    web_private_key { '0x97bea095e4d8da4e1a82cb3fb16edf31addbe7ab6de9c7a076b819917fd43e41' }
    valid_scope_id_token { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IiIsInNjb3BlIjoiaWQiLCJhZGRyZXNzIjoiMHhlNjUxNmYzNDkyOEUwMDg2MTg4N0YyODhFMTM1ZDljYUJDNTBFYTA0Iiwic2lsa2V5U2lnbmF0dXJlVGltZXN0YW1wIjowLCJzaWxrZXlTaWduYXR1cmUiOiIiLCJ1c2VyU2lnbmF0dXJlVGltZXN0YW1wIjoxNjA3NzkwMTY3LCJ1c2VyU2lnbmF0dXJlIjoiMHg1YWM1YmYzMDM1MzYzYzQxMGQwYTliZmMzMGQ3NDA5ZDAyZjFiZDJjZDA0NDY2YTgzNTc5Njk1OWY4ZGYzZGQ5MDZiNGI4MjA4MWUzYmMxM2M2OWVlYmFmZGZhODg1NzFlN2M2ZTA5Njg0ZjIxMmViOGNjMGI0ZDg1NWFjZmQxYjFjIiwibWlncmF0aW9uIjpmYWxzZSwiaWF0IjoxNjA3NzkwMTY2fQ.at2AfTPwru3avWFOqZ_9kAHPaQunEUFQ69AdO4CYkZA' }
    valid_scope_email_token { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFsaWFzSWRAcHJpdmF0ZXJlbGF5Iiwic2NvcGUiOiJlbWFpbCIsImFkZHJlc3MiOiIweGNiQWQxMzBmMGY2OGExODY3RkRlOWMxMGM2RTUzMGFFNjY2NzlFNjQiLCJzaWxrZXlTaWduYXR1cmVUaW1lc3RhbXAiOjE2MDc3OTAxNjYsInNpbGtleVNpZ25hdHVyZSI6IjB4YTZiOTlmZjY3MDY1ZTcwNGM0YzE4NzRhODcxZmM4ZjlkMWIyZGExNmRkZGYxOWQ5MjBlZjY1YjRiYTgxMjgwZTFlY2JiYzJjNjZjZDY2MGY4YWZjZjQwY2MzMmU5OWVkOGZmNTkzYTAwMDQ5OTQ3ODRiNzQzYTlhN2E1ZTg1MjMxYiIsInVzZXJTaWduYXR1cmVUaW1lc3RhbXAiOjE2MDc3OTAxNjcsInVzZXJTaWduYXR1cmUiOiIweGUyMTIwMWQ3N2U5NGI2MGUwMWIwYzUwMjg5MGRkYzI2NDkzOTQxYWViNWY1MmM4OWI1ZDlkMGM5Y2Y0MDFiZGQxMTExOTQ0MGRlMzZlN2MxNTJhNWVkY2ZmNTg0ZWNmYzcwMTE5OWM5NmJhZDQ4OTFmODEzODU3ZTMyMmE5MDQ4MWMiLCJtaWdyYXRpb24iOmZhbHNlLCJpYXQiOjE2MDc3OTAxNjd9.aewAUPZHTjlQFkQdOHYkTjr713kV6iTfFArwI7fl0b4' }
    invalid_token { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IjB4NjNmNUY0YjUzNjE3MTBiYzViMThBZTYyZGJjQzRkRTFiNjY0RjlCNEBwcml2YXRlcmVsYXkuc2lsa2V5LmlvIiwiYWRkcmVzcyI6IjB4RTIxNDA3ZDc4Q0FkQzQzNDczNTZGMjhiM0U2Mjc1NDM5MzM5RDA4NCIsInNpZ25hdHVyZSI6eyJyIjoiMHgyNmUxZGM0MzA4ZTViMDRiNGVhZWVlNzI0MWYwMjgzOTM0ZTgzYmE1OTMzYjM5NThkOTIyYmRiNmRkOTgzOTc3IiwicyI6IjB4MmMyOGQ2YmZmZWMxYThjOTFlNDFlODJjMWJjMzBmYzZkMTNjYzljNDk1Y2ZhNzQ3MjUzNzQ4OTVlMzhiZTdmNSIsIl92cyI6IjB4YWMyOGQ2YmZmZWMxYThjOTFlNDFlODJjMWJjMzBmYzZkMTNjYzljNDk1Y2ZhNzQ3MjUzNzQ4OTVlMzhiZTdmNSIsInJlY292ZXJ5UGFyYW0iOjEsInYiOjI4fSwiaWF0IjoxNjAyMTQ1MzU2fQ.kmmHfO7mGpHsoZoRcAis373rwNDyyzj3rT0-nbiJmN4' }
  end

  factory :callback_params_for_id, class: Silkey::Models::SSOParams do
    transient do
      with_signature { true }
    end

    params do
      {
        ssoTimestamp: 1_607_793_281,
        ssoRedirectUrl: 'https://silkey.io/',
        ssoCancelUrl: 'https://silkey.io/fail',
        ssoScope: 'id',
        ssoRefId: '123',
        ssoSignature: with_signature ? '0xbbdd34bc1c2be717a70a89046924fd871b3de6ce5a975297146cd9b07728f1a134f0c30cb9e801e451a38d9a626da0f61ef3450ed2e403fb572c2fa7d9920a3b1b' : ''
      }
    end
  end

  factory :callback_params_for_email, class: Silkey::Models::SSOParams do
    params do
      {
        ssoTimestamp: 1_607_793_281,
        ssoRedirectUrl: 'https://silkey.io/',
        ssoCancelUrl: 'https://silkey.io/fail',
        ssoScope: 'email',
        ssoRefId: '123',
        ssoSignature: '0x5ee1a242a35f087d89034367739a5eafb64c0d8389568db3042f011e5387fde326f0649a9b816364ea606e7ce79f403336b450b34d574842576d9bd095b6d76a1c'
      }
    end
  end
end
# rubocop:enable Layout/LineLength
