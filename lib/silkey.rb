# frozen_string_literal: true

require 'silkey/version'
require 'active_support/all'

module Silkey
  def self.root_path
    File.dirname __dir__
  end

  def self.bin_path
    File.join root_path, 'bin'
  end

  def self.lib_path
    File.join root_path, 'lib'
  end

  def self.abi_path
    File.join root_path, 'lib/silkey/abi'
  end
end
