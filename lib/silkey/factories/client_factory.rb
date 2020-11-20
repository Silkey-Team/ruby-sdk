# frozen_string_literal: true

module Silkey # :nodoc: all
  class ClientFactory
    def self.call(params = {})
      new(params).call
    end

    def initialize(params)
      @client_url = params.fetch(:client_url, Configuration.client_url)
      @log = params.fetch(:enable_logs, Configuration.enable_logs)
    end

    def call
      @client = new_client

      client
    end

    private

    attr_reader :client,
                :log,
                :client_url

    def new_client
      Ethereum::HttpClient.new(client_url, nil, log)
    end
  end
end
