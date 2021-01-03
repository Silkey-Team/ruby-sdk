# frozen_string_literal: true

module Silkey
  module Models
    ##
    # Generates message to sign based on plain object data (keys => values)
    #
    # @param email [string] verified email of the user
    #   IMPORTANT: if email in user profile is different, you should always update it with this one.
    #
    # @param scope [string]
    # @param address [string] ID of the user, this is also valid ethereum address, use this to identify user
    # @param userSignature [string] proof that request came from the user
    # @param userSignatureTimestamp [number] time when signature was crated
    # @param silkeySignature [string] proof that Silkey verified the email
    # @param silkeySignatureTimestamp [number] time when signature was crated
    # @param migration [boolean] true if user started migration to Silkey
    #
    class JwtPayload
      include Virtus.model

      # rubocop:disable Style/HashSyntax
      attribute :email, String, :writer => :private
      attribute :_scope, {}, :writer => :private, :reader => :private
      attribute :address, String, :writer => :private
      attribute :silkey_signature, String, :writer => :private
      attribute :silkey_signature_timestamp, Integer, :default => 0
      attribute :user_signature, String, :writer => :private
      attribute :user_signature_timestamp, Integer, :default => 0
      attribute :migration, Boolean, :writer => :private, :default => false
      # rubocop:enable Style/HashSyntax

      def scope
        _scope.keys.sort.join(Silkey::Settings.SCOPE_DIVIDER)
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

      def set_migrations(migrating)
        self.migration = migrating
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

      # rubocop:disable Metrics/AbcSize
      #
      ##
      #  Creates message that's need to be sign by user
      def message_to_sign_by_user
        data = {
          address: Silkey::Utils.strings_to_hex(['address']) + Silkey::Utils.remove0x(address).downcase,
          migration: Silkey::Utils.strings_to_hex(['migration']) + (migration ? '01' : '00'),
          scope: Silkey::Utils.strings_to_hex(['scope', scope]),
          userSignatureTimestamp: Silkey::Utils.strings_to_hex(['userSignatureTimestamp']) +
                                  Silkey::Utils.int_to_hex(user_signature_timestamp)
        }

        data.keys.sort.map { |k| data[k] }.join('')
      end
      # rubocop:enable Metrics/AbcSize

      def message_to_sign_by_silkey
        return '' if Silkey::Utils.empty?(email)

        if Silkey::Utils.empty?(silkey_signature_timestamp)
          self.silkey_signature_timestamp = Silkey::Utils.current_timestamp
        end

        "#{email.to_s.unpack('H*')[0]}#{Silkey::Utils.int_to_hex(silkey_signature_timestamp)}"
      end

      def validate
        raise "address is invalid: #{address}" unless Silkey::Utils.ethereum_address?(address)

        raise "user_signature is invalid: #{user_signature}" unless Silkey::Utils.signature?(user_signature)

        raise 'user_signature_timestamp is invalid' unless Silkey::Utils.timestamp?(user_signature_timestamp)

        return self if Silkey::Utils.empty?(scope) || scope == 'id'

        validate_scope_email
      end

      def import(data = {})
        return data if data.is_a?(Silkey::Models::JwtPayload)

        data.each do |k, v|
          var = k.to_s.underscore

          if var == 'scope'
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
          'scope', scope,
          'userSignatureTimestamp'
        ].map { |str| str.to_s.unpack('H*') }.join('')

        "#{str1_hex}#{adr_hex}#{str2_hex}"
      end

      def validate_scope_email
        raise 'email is empty' if Silkey::Utils.empty?(email)

        raise "silkey_signature is invalid: #{silkey_signature}" unless Silkey::Utils.signature?(silkey_signature)

        raise 'silkey_signature_timestamp is invalid' unless Silkey::Utils.timestamp?(silkey_signature_timestamp)

        self
      end
    end
  end
end
