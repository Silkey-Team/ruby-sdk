# frozen_string_literal: true

module Silkey
  module Models
    class SSOParams
      attr_accessor :params

      def initialize(params = {})
        @params = params
      end

      def sign(private_key)
        params[:ssoTimestamp] = Utils.current_timestamp unless Utils.timestamp?(params[:ssoTimestamp])

        params[:ssoSignature] = Silkey::Utils.sign_message(private_key, SDK.message_to_sign(params))

        self
      end

      def required_present?
        Silkey::Settings.SSO_PARAMS[:required].all? do |k|
          if Silkey::Utils.empty?(params[k.to_sym])
            Silkey::LoggerService.warn(
              "Missing #{k}. This parameters are required for Silkey SSO: " +
                Silkey::Settings.SSO_PARAMS[:required].join(', ')
            )

            return false
          end

          true
        end
      end

      def validate
        raise 'Missing required params' unless required_present?

        self
      end
    end
  end
end
