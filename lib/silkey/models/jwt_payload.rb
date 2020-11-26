# frozen_string_literal: true

module Silkey
  module Models
    class JwtPayload
      include Virtus.model

      SCOPE_DIVIDER = ','

      # rubocop:disable Style/HashSyntax
      attribute :address, String, :writer => :private
      attribute :email, String, :writer => :private
      attribute :silkey_signature, String, :writer => :private
      attribute :silkey_signature_timestamp, Integer
      attribute :user_signature, String, :writer => :private
      attribute :user_signature_timestamp, Integer
      attribute :ref_id, String, :writer => :private
      attribute :_scope, {}, :writer => :private, :reader => :private
      # rubocop:enable Style/HashSyntax

      def scope
        _scope.keys.sort.join(SCOPE_DIVIDER)
      end

      def scope_divider
        SCOPE_DIVIDER
      end

      # rubocop:disable Naming/AccessorMethodName
      def set_scope(scope)
        return self if Silkey::Utils.empty?(scope)

        _scope[scope] = true
        self
      end

      def set_address(addr)
        raise "`#{addr}` is not ethereum address" unless Silkey::Utils.ethereum_address?(addr)

        self.address = addr
        self
      end

      def set_email(email)
        self.email = email
        self
      end

      def set_ref_id(ref_id)
        self.ref_id = ref_id
        self
      end

      def set_user_signature(sig, timestamp)
        raise "user signature invalid: `#{sig}`" unless Silkey::Utils.signature?(sig)
        raise 'empty user signature timestamp' if Silkey::Utils.empty?(timestamp)

        self.user_signature = sig
        self.user_signature_timestamp = timestamp
        self
      end

      def set_silkey_signature(sig, timestamp)
        raise "silkey signature invalid: `#{sig}`" unless Silkey::Utils.signature?(sig)
        raise 'empty silkey signature timestamp' if Silkey::Utils.empty?(timestamp)

        self.silkey_signature = sig
        self.silkey_signature_timestamp = timestamp
        self
      end
      # rubocop:enable Naming/AccessorMethodName

      ##
      #  Creates message that's need to be sign by user
      def message_to_sign_by_user
        if !Silkey::Utils.empty?(address) && Silkey::Utils.empty?(user_signature_timestamp)
          self.user_signature_timestamp = Silkey::Utils.current_timestamp
        end

        return pack_payload_to_hex if Silkey::Utils.empty?(user_signature_timestamp)

        "#{pack_payload_to_hex}#{Silkey::Utils.int_to_hex(user_signature_timestamp.to_s)}"
      end

      def message_to_sign_by_silkey
        return '' if Silkey::Utils.empty?(email)

        if Silkey::Utils.empty?(silkey_signature_timestamp)
          self.silkey_signature_timestamp = Silkey::Utils.current_timestamp
        end

        str_hex = [
          'email', email,
          'silkeySignatureTimestamp'
        ].map { |str| str.to_s.unpack('H*') }.join('')

        "#{str_hex}#{Silkey::Utils.int_to_hex(silkey_signature_timestamp.to_s)}"
      end

      def validate
        raise "address is invalid: #{address}" unless Silkey::Utils.ethereum_address?(address)

        unless Silkey::Utils.signature?(user_signature)
          raise "user_signature is invalid: #{user_signature}"
        end

        raise 'user_signature_timestamp is empty' if Silkey::Utils.empty?(user_signature_timestamp)

        return self if Silkey::Utils.empty?(scope) || scope == 'id'

        validate_scope_email
      end

      def import(hash)
        hash.each do |k, v|
          var = k.to_s.underscore

          if k == 'scope'
            set_scope(v)
          else
            instance_variable_set("@#{var}", v)
          end
        end

        self
      end

      private

      def pack_payload_to_hex
        str1_hex = 'address'.unpack('H*')[0]
        adr_hex = Silkey::Utils.remove0x(address).downcase

        str2_hex = [
          'refId', ref_id.to_s,
          'scope', scope,
          'userSignatureTimestamp'
        ].map { |str| str.to_s.unpack('H*') }.join('')

        "#{str1_hex}#{adr_hex}#{str2_hex}"
      end

      def validate_scope_email
        raise 'email is empty' if Silkey::Utils.empty?(email)

        unless Silkey::Utils.signature?(silkey_signature)
          raise "silkey_signature is invalid: #{silkey_signature}"
        end

        if Silkey::Utils.empty?(silkey_signature_timestamp)
          raise 'silkey_signature_timestamp is empty'
        end

        self
      end
    end
  end
end
