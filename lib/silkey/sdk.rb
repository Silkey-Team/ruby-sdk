# frozen_string_literal: true

module Silkey
  class SDK
    class << self
      SSO_PARAMS_PREFIX = 'sso'

      ##
      # Generates message to sign based on plain object data (keys => values)
      #
      # @param to_sign [Hash] hash object
      #
      # @return [string] message to sign
      #
      # @example:
      #
      #   Silkey::SDK.message_to_sign({ ssoRedirectUrl: 'http://silkey.io', ssoCancelUrl: 'http://silkey.io/fail' });
      #
      # returns
      #
      #   'ssoRedirectUrl=http://silkey.io::ssoCancelUrl=http://silkey.io/fail'
      #
      def message_to_sign(to_sign = {})
        msg = []

        to_sign.keys.sort.each do |k|
          if 'ssoSignature'.to_sym != k && k[0..SSO_PARAMS_PREFIX.length - 1] == SSO_PARAMS_PREFIX && !to_sign[k].nil?
            msg.push("#{k}=#{to_sign[k]}")
          end
        end

        msg.join(Silkey::Settings.MESSAGE_TO_SIGN_GLUE)
      end

      ##
      # Generates all needed parameters (including signature) for requesting Silkey SSO
      #
      # @param private_key [string] secret private key of domain owner
      #
      # @param data_to_sign [Hash] Hash object with parameters:
      #   - ssoRedirectUrl*,
      #   - ssoCancelUrl*,
      #   - ssoRedirectMethod,
      #   - ssoScope,
      #   - ssoTimestamp
      #   marked with * are required by Silkey
      #
      # @return [Hash] parameters for SSO as key -> value, they all need to be set in URL
      #
      # @throws on missing required data
      #
      # @example
      #
      #   data = { ssoRedirectUrl: 'https://your-website', ssoRefId: '12ab' }
      #   Silkey::SDK.generate_sso_request_params(private_key, data)
      #
      def generate_sso_request_params(private_key, data_to_sign)
        raise '`private_key` is empty' if Silkey::Utils.empty?(private_key)

        Silkey::Models::SSOParams.new(data_to_sign.clone).sign(private_key).validate.params
      end

      ##
      # Verifies JWT token payload
      #
      # @see https://jwt.io/ for details about token payload data
      #
      # @param token [string] JWT token returned by Silkey
      #
      # @param callback_params [string] params used to do SSO call
      #
      # @param website_eth_address [string] public ethereum address of website owner
      #
      # @param silkey_eth_address [string] public ethereum address of Silkey
      #
      # @param expiration_time [number] expiration time of token in seconds
      #
      # @return [JwtPayload|null] null when signature(s) are invalid, otherwise token payload
      #
      # @throws when token is invalid or data are corrupted
      #
      # @example
      #
      #   Silkey::SDK.token_payload_verifier(
      #     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG'\
      #     '9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
      #     {ssoSignature: '...', ...},
      #     website_eth_address,
      #     Silkey::SDK.fetch_silkey_eth_address
      #   )
      #
      def token_payload_verifier(token,
                                 callback_params,
                                 website_eth_address,
                                 silkey_eth_address = nil,
                                 expiration_time = 30)
        payload = token_payload(token)

        return nil unless Verifier.valid_age?(payload, expiration_time)

        return nil if Silkey::Verifier.user_signature_valid?(payload) == false

        return nil if Silkey::Verifier.silkey_signature_valid?(payload, silkey_eth_address) == false

        return nil if Silkey::Verifier.website_signature_valid?(callback_params, website_eth_address) == false

        jwt_payload = Silkey::Models::JwtPayload.new.import(payload)

        Silkey::Verifier.require_params_for_scope(jwt_payload.scope, jwt_payload.attributes)

        jwt_payload
      rescue StandardError => e
        logger.warn(e.full_message)
        nil
      end

      ##
      # Fetches public ethereum Silkey address (directly from blockchain).
      # This address can be used for token verification
      #
      # @see List of Silkey contracts addresses: https://github.com/Silkey-Team/silkey-sdk#silkey-sdk
      #
      def fetch_silkey_eth_address
        silkey_address = Silkey::RegistryContract.get_address(Silkey::Settings.SILKEY_REGISTERED_BY_NAME)

        raise "Invalid silkey address: #{silkey_address}" unless Silkey::Utils.ethereum_address?(silkey_address)

        silkey_address
      end

      private

      def token_payload(token)
        # Set password to nil and validation to false otherwise this won't work
        decoded = JWT.decode token, nil, false
        decoded[0]
      end

      def logger
        Silkey::LoggerService
      end
    end
  end
end
