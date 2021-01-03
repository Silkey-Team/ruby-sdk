# Silkey-SDK for Ruby

## Development

After checking out the repo, run `bin/setup` to install dependencies.  
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Deploy gem

```
rm -rf doc/
bundle exec yardoc 

bundle exec gem build

# RubyGems saves the credentials in ~/.gem/credentials
bundle exec gem push silkey-sdk-...gem

# remove gem
bundle exec gem yank silkey-sdk -v 0.0.0
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
Silkey::Configuration.client_url = 'http://localhost:8545'
Silkey::Configuration.registry_contract_address = '0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf'
Silkey::RegistryContract.get_address('Name')
```

### Tests and Linters

```bash
bundle exec rspec
bundle exec rubocop --fix
bundle exec rubocop --auto-correct-all
```

#### Init setup environment

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
