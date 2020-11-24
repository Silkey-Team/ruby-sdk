# frozen_string_literal: true

module Silkey
  class SDK
    class << self
      ##
      # Generates message to sign based on plain object data (keys => values)
      #
      # @param to_sign [Hash] hash object
      #
      # @return [string] message to sign
      #
      # @example:
      #
      #   Silkey::SDK.message_to_sign({ :redirectUrl => 'http://silkey.io', :refId => 1 });
      #
      # returns
      #
      #   'redirectUrl=http://silkey.io::refId=1'
      #
      def message_to_sign(to_sign = {})
        msg = []
        to_sign.keys.sort.each do |k|
          if Silkey::Utils.empty?(to_sign[k])
            msg.push("#{k}=")
          else
            msg.push("#{k}=#{to_sign[k]}")
          end
        end

        msg.join('::')
      end

      ##
      # Generates all needed parameters (including signature) for requesting Silkey SSO
      #
      # @param private_key [string] secret private key of domain owner
      #
      # @param params [Hash] Hash object with parameters:
      #   - redirectUrl*,
      #   - redirectMethod*,
      #   - cancelUrl*,
      #   - refId,
      #   - scope,
      #   - ssoTimestamp*
      #   marked with * are required by Silkey
      #
      # @return [Hash] parameters for SSO as key -> value, they all need to be set in URL
      #
      # @example
      #
      #   data = { :redirectUrl => 'https://your-website', :refId => '12ab' }
      #   Silkey::SDK.generate_sso_request_params(private_key, data)
      #
      def generate_sso_request_params(private_key, params)
        raise "params[:redirectUrl] is empty" if Silkey::Utils.empty?(params[:redirectUrl])

        raise "params[:cancelUrl] is empty" if Silkey::Utils.empty?(params[:cancelUrl])

        keys = %w(redirectUrl redirectMethod cancelUrl ssoTimestamp refId scope)

        data_to_sign = keys.reduce({}) do |acc, k|
          if Silkey::Utils.empty?(params[k.to_sym])
            case k
            when 'ssoTimestamp'
              acc[k.to_sym] = Silkey::Utils.current_timestamp
            when 'scope'
              acc[k.to_sym] = 'id'
            else
              # type code here
            end
          else
            acc[k.to_sym] = params[k.to_sym]
          end

          acc
        end

        puts data_to_sign
        message = message_to_sign(data_to_sign)
        data_to_sign['signature'] = Silkey::Utils.sign_message(private_key, message)

        data_to_sign
      end

      ##
      # Verifies JWT token payload
      #
      # @see https://jwt.io/ for details about token payload data
      #
      # @param token [string] JWT token returned by Silkey
      #
      # @param silkey_public_key [string] public ethereum address of Silkey
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
      #     Silkey::SDK.fetch_silkey_public_key
      #   )
      #
      def token_payload_verifier(token, silkey_public_key = nil)
        payload = token_payload(token)

        if silkey_signature_valid?(payload, silkey_public_key) != false &&
           user_signature_valid?(payload) != false
          return Silkey::Models::JwtPayload.new.import(payload)
        end

        nil
      rescue
        nil
      end

      ##
      # Fetches public ethereum Silkey address (directly from blockchain).
      # This address can be used for token verification
      #
      # @see List of Silkey contracts addresses: https://github.com/Silkey-Team/silkey-sdk#silkey-sdk
      #
      def fetch_silkey_public_key
        public_key = Silkey::RegistryContract.get_address('Hades')

        raise "Invalid public key: #{public_key}" unless Silkey::Utils.ethereum_address?(public_key)

        public_key
      end

      private

      def token_payload(token)
        # Set password to nil and validation to false otherwise this won't work
        decoded = JWT.decode token, nil, false
        decoded[0]
      end

      def user_signature_valid?(payload)
        jwt_payload = Silkey::Models::JwtPayload.new.import(payload)
        utils = Silkey::Utils

        if utils.empty?(jwt_payload.address) ||
           utils.empty?(jwt_payload.user_signature) ||
           utils.empty?(jwt_payload.user_signature_timestamp)
          logger.warn('Verification failed, missing user signature/timestamp and/or address')
          return false
        end

        signer = Silkey::Utils
                 .verify_message(jwt_payload.message_to_sign_by_user, jwt_payload.user_signature)

        success = signer == jwt_payload.address

        unless success
          logger.warn("user_signature_valid?: expect #{signer} to be equal #{jwt_payload.address}")
        end

        success
      rescue StandardError => e
        logger.error(e)
        false
      end

      def silkey_signature_valid?(payload, silkey_public_key)
        jwt_payload = Silkey::Models::JwtPayload.new.import(payload)
        utils = Silkey::Utils

        if utils.empty?(jwt_payload.email) && utils.empty?(jwt_payload.silkey_signature)
          return nil
        end

        if utils.empty?(jwt_payload.email) ^ utils.empty?(jwt_payload.silkey_signature)
          logger.warn('Verification failed, missing silkey signature or email')
          return false
        end

        if utils.empty?(jwt_payload.silkey_signature_timestamp)
          logger.warn('Verification failed, missing silkey signature timestamp')
          return false
        end

        signer = Silkey::Utils.verify_message(
          jwt_payload.message_to_sign_by_silkey, jwt_payload.silkey_signature
        )

        if Silkey::Utils.empty?(silkey_public_key)
          logger.warn('You are using verification without checking silkey signature. '\
                      'We strongly recommended to turn on full verification. '\
                      'This option can be deprecated in the future')
          return true
        end

        success = signer == silkey_public_key

        unless success
          logger.warn("silkey_signature_valid?: expect #{signer} to be equal #{silkey_public_key}")
        end

        success
      rescue StandardError => e
        logger.error(e)
        false
      end

      def logger
        Silkey::LoggerService
      end
    end
  end
end
