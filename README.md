# Silkey-Ruby-SDK

Welcome to your new gem! Put your Ruby code in the file `lib/silkey`.  
To experiment with that code, run `bin/console` for an interactive prompt.

## Integration

Add this line to your application's Gemfile:

```ruby
source 'https://hwGZD769AGZu5Wyzp87F@repo.fury.io/silkey/' do
  gem 'silkey-sdk'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silkey-sdk

### Usage

#### Configuration

```rb
Silkey::Configuration.setup do |config|
  config.client_url =  'http://localhost:8545'
  config.registry_contract_address =  '0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf'
  config.enable_logs = false
end
```

#### Methods


```rb
- Silkey::SDK.fetch_silkey_public_key
- Silkey::SDK.message_to_sign(hash)
- Silkey::SDK.generate_sso_request_params(private_key, hash)
- Silkey::SDK.token_payload_verifier(token, silkey_public_key = nil)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Deploy gem

```
bundle exec rdoc --main DOC.rdoc
bundle exec rdoc --markup DOC
bundle exec rdoc --main DOC.rdoc -x "lib/(?!sdk.rb).* lib/sdk.rb LICENSE README.rdoc"
bundle exec rdoc --main README.rdoc --exclude Gemfile*
bundle exec rake build

```

To install this gem onto your local machine, run `bundle exec rake install`.  
To release a new version, update the version number in `version.rb`, and then run  
`bundle exec rake release`, which will create a git tag for the version,  
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Tests

### Interactive console

To quickly test you code while developing you can do:

```sh
./bin/console
```

```rb
# config
Silkey::Configuration.client_url = 'http://localhost:8545' || https://kovan.infura.io/v3/:id
Silkey::Configuration.registry_contract_address = '0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf'
Silkey::RegistryContract.get_address('Name')
```

### Tests and Linters

```bash
bundle exec rspec
bundle exec rubocop --fix
```

#### Init environment

```
https://github.com/rbenv/rbenv#installation
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# steps for fixing abort issue about ethereum.rb gem 

brew update & brew upgrade & brew install openssl
cd /usr/local/opt/openssl@1.1/lib
cp libssl.1.1.dylib libcrypto.1.1.dylib /usr/local/lib/
cd /usr/local/lib
sudo ln -s libssl.1.1.dylib libssl.dylib
sudo ln -s libcrypto.1.1.dylib libcrypto.dylib

https://github.com/se3000/ruby-eth/issues/47

which ruby

gem install bundler
bundle config set path '.bundle'
bundle install
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
