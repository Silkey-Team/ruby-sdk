# frozen_string_literal: true

module Silkey # :nodoc: all
  class Contract < SimpleDelegator
    def initialize(contract, client)
      super(contract)
      @contract = contract
      @client = client
      _, @functions, = Ethereum::Abi.parse_abi(contract.abi)
    end

    def call_func_for_block(func_name, default_block = 'latest', *args)
      fun = @functions.find { |f| f.name == func_name.to_s }

      raise 'FunctionNotFoundError', func_name unless fun

      raw_result = @client.send_command('eth_call',
                                        FrozenArray.new(@contract.call_args(fun, args),
                                                        default_block))['result']

      output = Ethereum::Decoder.new.decode_arguments(fun.outputs, raw_result)

      return output[0] if output.length == 1

      output
    end

    class FrozenArray < Array
      def initialize(*args)
        super(args)
      end

      def <<(_)
        self
      end
    end
  end
end
