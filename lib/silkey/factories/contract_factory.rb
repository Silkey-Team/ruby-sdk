# frozen_string_literal: true

module Silkey # :nodoc: all
  class ContractFactory
    def self.call(params)
      new(params).call
    end

    def initialize(params = {})
      @abi =
        params.fetch(:abi)
      @address =
        params.fetch(:address)
      @client_url =
        params.fetch(:client_url, Configuration.client_url)
      @name =
        params.fetch(:name)
    end

    def call
      @contract = create_contract

      contract
    end

    private

    attr_reader :abi,
                :address,
                :contract,
                :client_url,
                :name

    def client
      ClientFactory.call(client_url: client_url)
    end

    def create_contract
      Silkey::Contract.new(Ethereum::Contract.create(
                             name: name,
                             address: address,
                             abi: abi,
                             client: client
                           ), client)
    end
  end
end
