# Silkey SDK for Ruby

![Silkey Logo](https://raw.githubusercontent.com/Silkey-Team/brand/master/silkey-word-black.png)

[![GitHub version](https://badge.fury.io/gh/Silkey-Team%2Fsilkey-sdk.svg)](https://badge.fury.io/gh/Silkey-Team%2Fsilkey-sdk)
[![Gem Version](https://badge.fury.io/rb/silkey-sdk.svg)](https://badge.fury.io/rb/silkey-sdk)

## Integration

### Configuration

```rb
Silkey::Configuration.setup do |config|
  # for local development, use local provider url eg 'http://localhost:8545'
  # for testing, we recommend using infura.io:
  # - for sandbox: https://rinkeby.infura.io/v3/:id 
  # - for production: https://mainnet.infura.io/v3/:id 
  config.client_url =  'http://localhost:8545'
  config.registry_contract_address =  '--silky-registry-contract-address--'
  config.enable_logs = false
end
```

[List of Silkey smart contract addresses.](https://github.com/Silkey-Team/silkey-sdk#smart-contracts) 

### Sign In with Silkey

#### Making request

| Parameter         | Required  | Type     | Desc 
| ----------------- |:---------:| -------- | ----- 
| ssoSignature      | yes       | string   | Domain owner signature
| ssoTimestamp      | yes       | number   | Time of signing SSO request
| ssoRedirectUrl    | yes       | string   | Where to redirect user with token after sign in
| ssoCancelUrl      | yes       | string   | Where to redirect user on error
| ssoRedirectMethod | no        | GET/POST | How to redirect user after sign in, default is POST
| ssoRefId          | no        | string   | Any value, you may use it to identify request
| ssoScope          | no        | string   | Scope of data to return in a token payload: `id` (default) returns only user address, `email` returns address + email


```rb
params = { ssoRedirectUrl: 'https://your-website', ssoRefId: '12ab' }
sso_params = Silkey::SDK.generate_sso_request_params(private_key, params)
```

#### On request callback page

Callback will be done via POST (default) or GET, based on `ssoRedirectMethod`.

Callback params contains:
- sso parameters that were used to make SSO call
- `token`.

`token` - get if from request params

`ssoRequestParams` - get if from request params (it can be send via POST or GET, based on `ssoRedirectMethod`)

```rb
silkey_eth_address = Silkey::SDK.fetch_silkey_eth_address
Silkey::SDK.token_payload_verifier(token, silkey_eth_address)
```

## Recommendations and Migration

See [recommendation and migration](https://github.com/Silkey-Team/silkey-sdk#recommendations) sections on main SDK package.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
