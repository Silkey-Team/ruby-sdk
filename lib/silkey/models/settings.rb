# frozen_string_literal: true

module Silkey # :nodoc: all
  class Settings
    # rubocop:disable Naming/MethodName
    class << self
      attr_accessor :SSO_PARAMS
      attr_accessor :JWT
      attr_accessor :MESSAGE_TO_SIGN_GLUE
      attr_accessor :SCOPE_DIVIDER
      attr_accessor :SILKEY_REGISTERED_BY_NAME
    end
    # rubocop:enable Naming/MethodName

    self.SSO_PARAMS = {
      required: %w(ssoSignature ssoRedirectUrl ssoCancelUrl ssoTimestamp),
      optional: %w(ssoRefId ssoScope ssoRedirectMethod),
      prefix: 'sso'
    }

    self.JWT = {
      id: {
        required: %w(address)
      },
      email: {
        required: %w(address email)
      }
    }

    self.MESSAGE_TO_SIGN_GLUE = '::'
    self.SCOPE_DIVIDER = ','
    self.SILKEY_REGISTERED_BY_NAME = 'Hades'
  end
end
