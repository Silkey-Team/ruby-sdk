# frozen_string_literal: true

module Silkey
  class Configuration
    class << self
      attr_accessor :client_url
      attr_accessor :registry_contract_abi
      attr_accessor :registry_contract_address
      attr_accessor :enable_logs

      def setup
        yield self
      end
    end

    self.client_url = 'http://localhost:8545'
    self.enable_logs = false

    self.registry_contract_abi =
      File.read(File.expand_path('./registry_contract_abi.json', Silkey.abi_path))

    self.registry_contract_address = ''
  end
end
