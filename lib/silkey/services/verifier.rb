# frozen_string_literal: true

module Silkey # :nodoc: all
  class Verifier
    class << self
      def require_params_for_scope(scope, data)
        scope_arr = scope_to_arr(scope)

        scope_arr.each do |scope_key|
          raise "scope `#{scope_key}` is not supported" unless Silkey::Settings.JWT.key?(scope_key.to_sym)

          Silkey::Settings.JWT[scope_key.to_sym][:required].each do |item|
            if Silkey::Utils.empty?(data[item.to_sym])
              raise "`#{item}` parameter is required for selected scope: #{scope_key}"
            end
          end
        end
      end

      def valid_age?(jwt_payload, expiration_time)
        if expiration_time <= 0
          logger.warn("You set token expiration time to #{expiration_time}. " \
                       'That mean token age will not be verified. ' \
                       'We strongly recommended to set expiration time between 5s - 60s for security reasons.')

          return true
        end

        if expiration_time > 100
          logger.warn("You set token expiration time to #{expiration_time}. " \
                       'We strongly recommended to set expiration time between 5s - 30s for security reasons.')
        end

        age = Silkey::Utils.current_timestamp - jwt_payload.user_signature_timestamp

        if age > expiration_time
          logger.warn("token expired, expected age #{expiration_time}s but got #{age}s")
          return false
        end

        if expiration_time.negative?
          logger.warn('token from the future... https://www.youtube.com/watch?v=FWG3Dfss3Jc')
          return false
        end

        true
      end

      ##
      #
      # @param sso_params [Hash|Silkey::Models::SSOParams.params] hash object
      #
      # @param website_owner_address [string]
      #
      # @return [boolean]
      #
      def website_signature_valid?(sso_params, website_owner_address)
        if Silkey::Utils.empty?(sso_params[:ssoSignature])
          Silkey::LoggerService.warn('ssoSignature is empty')
          return false
        end

        message = Silkey::SDK.message_to_sign(sso_params)
        signer = Silkey::Utils.verify_message(message, sso_params[:ssoSignature])

        success = signer == website_owner_address

        logger.warn("website_signature_valid?: expect #{signer} to be equal #{website_owner_address}") unless success

        success
      rescue StandardError => e
        logger.error(e)
        false
      end

      def user_signature_valid?(payload)
        jwt_payload = Silkey::Models::JwtPayload.new.import(payload)

        return false unless can_validate_user_signature?(jwt_payload)

        signer = Silkey::Utils
                 .verify_message(jwt_payload.message_to_sign_by_user, jwt_payload.user_signature)

        success = signer == jwt_payload.address

        logger.warn("user_signature_valid?: expect #{signer} to be equal #{jwt_payload.address}") unless success

        success
      rescue StandardError => e
        logger.error(e)
        false
      end

      # rubocop:disable Metrics/AbcSize
      def silkey_signature_valid?(payload, silkey_public_key = nil)
        jwt_payload = Silkey::Models::JwtPayload.new.import(payload)

        return nil if cant_validate_silky_signature?(jwt_payload)

        return false unless silkey_sig_check_requirements?(jwt_payload)

        signer = Silkey::Utils.verify_message(
          jwt_payload.message_to_sign_by_silkey, jwt_payload.silkey_signature
        )

        if Silkey::Utils.empty?(silkey_public_key)
          logger.warn('You are using verification without checking silkey signature. '\
                      'We strongly recommended to turn on full verification. '\
                      'This option can be deprecated in the future')
          return true
        end

        success = signer.downcase == silkey_public_key.downcase

        logger.warn("silkey_signature_valid?: expect #{signer} to be equal #{silkey_public_key}") unless success

        success
      rescue StandardError => e
        logger.error(e)
        false
      end
      # rubocop:enable Metrics/AbcSize

      private

      def scope_to_arr(scope)
        raise 'scope is empty' if scope.empty?

        return scope unless scope.is_a?(String)

        arr = scope.split(Silkey::Settings.SCOPE_DIVIDER).reduce([]) do |acc, v|
          return acc if v.empty?

          acc.push(v)
        end

        raise 'scope is empty' if arr.empty?

        arr
      end

      def can_validate_user_signature?(jwt_payload)
        if Silkey::Utils.empty?(jwt_payload.address)
          logger.warn('Verification failed, missing user address')
          return false
        end

        if Silkey::Utils.empty?(jwt_payload.user_signature)
          logger.warn('Verification failed, missing user signature')
          return false
        end

        if Silkey::Utils.empty?(jwt_payload.user_signature_timestamp)
          logger.warn('Verification failed, missing user signature timestamp ')
          return false
        end

        true
      end

      def cant_validate_silky_signature?(jwt_payload)
        empty_email = Silkey::Utils.empty?(jwt_payload.email)
        empty_sig = Silkey::Utils.empty?(jwt_payload.silkey_signature)

        empty_email && empty_sig
      end

      def silkey_sig_check_requirements?(jwt_payload)
        empty_email = Silkey::Utils.empty?(jwt_payload.email)
        empty_sig = Silkey::Utils.empty?(jwt_payload.silkey_signature)

        if empty_email ^ empty_sig
          logger.warn('Verification failed, missing silkey signature or email')
          return false
        end

        if Silkey::Utils.empty?(jwt_payload.silkey_signature_timestamp)
          logger.warn('Verification failed, missing silkey signature timestamp')
          return false
        end

        true
      end

      def logger
        Silkey::LoggerService
      end
    end
  end
end
