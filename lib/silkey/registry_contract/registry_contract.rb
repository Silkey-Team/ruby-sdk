# frozen_string_literal: true

module Silkey # :nodoc: all
  class RegistryContract
    CONTRACT_NAME = 'RegistryContractInstance'

    class << self
      def get_address(name)
        new.get_address(name)
      end
    end

    attr_reader :contract

    delegate :call, to: :contract, prefix: true

    def initialize(params = {})
      @contract = ContractFactory.call(default_params.merge(params))
    end

    def get_address(name)
      Silkey::Utils.add0x(contract_call.get_address(name))
    end

    def default_params
      {
        name: CONTRACT_NAME,
        address: Configuration.registry_contract_address,
        abi: Configuration.registry_contract_abi,
      }.freeze
    end
  end
end
