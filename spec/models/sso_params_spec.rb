# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Silkey::Models::SSOParams, type: :model do
  subject { described_class.new }

  describe 'validate' do
    it 'raise error when missing required params' do
      expect { subject.validate }.to raise_error(/Missing required params/)

      subject.params[:ssoSignature] = '1'
      expect { subject.validate }.to raise_error(/Missing required params/)

      subject.params[:ssoRedirectUrl] = '1'
      expect { subject.validate }.to raise_error(/Missing required params/)

      subject.params[:ssoCancelUrl] = '1'
      expect { subject.validate }.to raise_error(/Missing required params/)

      subject.params[:ssoTimestamp] = 1

      expect { subject.validate }.to_not raise_error
    end
  end

  describe 'has_required?' do
    it 'return FALSE when missing required params' do
      expect(subject.required_present?).to eq(false)
    end

    it 'return true when has all required params' do
      subject.params = { ssoSignature: 1, ssoRedirectUrl: 2, ssoCancelUrl: 3, ssoTimestamp: 4 }
      expect(subject.required_present?).to eq(true)
    end
  end
end
