# frozen_string_literal: true

module Silkey
  class SDK
    class << self
      def message_to_sign(hash = {})
        msg = []
        hash.keys.sort.each do |k|
          if Silkey::Utils.empty?(hash[k])
            msg.push("#{k}=")
          else
            msg.push("#{k}=#{hash[k]}")
          end
        end

        msg.join('::')
      end

      def generate_sso_request_params(private_key, hash)
        redirect_url = hash[:redirectUrl] || ''
        cancel_url = hash[:cancelUrl] || ''
        sso_timestamp = hash[:ssoTimestamp] || Silkey::Utils.current_timestamp
        ref_id = hash[:refId] || ''
        scope = hash[:scope] || ''

        message = message_to_sign({
                                    redirectUrl: redirect_url,
                                    cancelUrl: cancel_url,
                                    ssoTimestamp: sso_timestamp,
                                    refId: ref_id,
                                    scope: scope
                                  })

        {
          signature: Silkey::Utils.sign_message(private_key, message),
          ssoTimestamp: sso_timestamp,
          redirectUrl: redirect_url,
          cancelUrl: cancel_url,
          refId: ref_id,
          scope: scope
        }
      end

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
