![Silkey Logo](https://raw.githubusercontent.com/Silkey-Team/brand/master/silkey-word-black.png)

# Silkey SDK for Ruby

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

| Parameter        | Required  | Type     | Desc 
| ---------------- |:---------:| -------- | ----- 
| signature        | yes       | string   | Domain owner signature
| ssoTimestamp     | yes       | number   | Time of signing SSO request
| redirectUrl      | yes       | string   | Where to redirect user with token after sign in
| redirectMethod   | no        | GET/POST | How to redirect user after sign in, default is POST
| cancelUrl        | yes       | string   | Where to redirect user on error
| refId            | no        | string   | It will be return with user token, you may use it to identify request
| scope            | no        | string   | Scope of data to return in a token payload: `id` (default) returns only user address, `email` returns address + email


```rb
params = { :redirectUrl => 'https://your-website', :refId => '12ab' }
sso_params = Silkey::SDK.generate_sso_request_params(private_key, params)
```

#### On request callback page

`token` - get if from request params (it can be send via POST or GET, based on `redirectMethod`) 

```rb
silkey_public_key = Silkey::SDK.fetch_silkey_public_key
Silkey::SDK.token_payload_verifier(token, silkey_public_key)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
