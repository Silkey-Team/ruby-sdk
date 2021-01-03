# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::Settings, type: :model do
  subject { described_class }

  it { expect(described_class.SCOPE_DIVIDER).to eq(',') }

  it { expect(described_class.MESSAGE_TO_SIGN_GLUE).to eq('::') }

  it { expect(described_class.SILKEY_REGISTERED_BY_NAME).to eq('Hades') }

  it { expect(described_class.SSO_PARAMS[:prefix]).to eq('sso') }
end
