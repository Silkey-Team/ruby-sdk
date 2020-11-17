# Silkey-SDK for Ruby

[logo]

[slogan]


## Integration

### Configuration

```rb
Silkey::Configuration.setup do |config|
  config.client_url =  'http://localhost:8545'              # for local development
  config.client_url =  'https://kovan.infura.io/v3/:id'     # for real
  config.registry_contract_address =  '--silky-registry-contrract-address--'
  config.enable_logs = false
end
```

[List of Silkey contract address.](https://github.com/Silkey-Team/silkey-sdk#silkey-sdk) 

### Sign In with Silkey

#### Making request

[List of request parameters.](https://github.com/Silkey-Team/silkey-sdk#silkey-sdk) 


```rb
- Silkey::SDK.message_to_sign({params})
- Silkey::SDK.generate_sso_request_params(private_key, hash)
```

#### On request callback page

`token` - get if from request params (it can be send either via POST or GET) 

```rb
silkey_public_key = Silkey::SDK.fetch_silkey_public_key
Silkey::SDK.token_payload_verifier(token, silkey_public_key)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
