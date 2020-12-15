# frozen_string_literal: true

module Silkey
  class Utils
    class << self
      def empty?(string)
        string.nil? || string.to_s == ''
      end

      def remove0x(string)
        string.to_s.sub('0x', '')
      end

      def add0x(string)
        return string if string.to_s[0..1] == '0x'

        "0x#{string}"
      end

      def hex?(string)
        return false if empty?(string)

        !remove0x(string)[/\H/]
      end

      def str_to_bytes32(string)
        return '' if empty?(string)

        hex = string.to_s.unpack('H*')[0]
        "0x#{hex}#{['0'].cycle(64 - hex.length).to_a.join('')}"
      end

      def empty_hex?(string)
        return true if empty?(string)
        return false unless hex?(string)

        !remove0x(string).split('').reduce(false) { |non_zero, c| c != '0' || non_zero }
      end

      def private_key?(string)
        hex_and_length?(string, 64)
      end

      def ethereum_address?(string)
        hex_and_length?(string, 40)
      end

      def signature?(string)
        hex_and_length?(string, 130)
      end

      def current_timestamp
        Time.now.getutc.to_i
      end

      def int_to_hex(int)
        return '' if empty?(int)

        hex = int.to_i.to_s(16)

        return hex if hex.length.even?

        "0#{hex}"
      end

      def strings_to_hex(arr)
        arr.map { |str| str.to_s.unpack('H*') }.join('')
      end

      def sign_message(private_key, message)
        wallet = Eth::Key.new priv: Silkey::Utils.remove0x(private_key)
        Silkey::Utils.add0x(wallet.personal_sign(message))
      end

      def sign_plain_message(private_key, message)
        wallet = Eth::Key.new priv: Silkey::Utils.remove0x(private_key)
        bin_signature = wallet.sign(message)
        Eth::Utils.bin_to_hex(bin_signature)
      end

      def verify_message(message, signature)
        public_key = Eth::Key.personal_recover(message, signature)
        return nil if public_key.nil?

        Eth::Utils.public_key_to_address(public_key)
      end

      def verify_plain_message(message, signature)
        bin_signature = Eth::Utils.hex_to_bin(signature)
        hash = Eth::Utils.keccak256(message)
        public_key = Eth::OpenSsl.recover_compact(hash, bin_signature)
        return nil if public_key.nil?

        Eth::Utils.public_key_to_address(public_key)
      end

      private

      def hex_and_length?(string, len)
        return false if empty_hex?(string)
        return false unless hex?(string)

        remove0x(string).length == len
      end
    end
  end
end
