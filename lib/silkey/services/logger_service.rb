# frozen_string_literal: true

module Silkey # :nodoc: all
  class LoggerService
    class << self
      delegate :info, :debug, :error, :warn, to: :logger

      def logger
        if @logger.nil?
          @logger = Logger.new(STDOUT)
          @logger.level = Logger::INFO
          @logger.datetime_format = '%a %d-%m-%Y %H%M '
        end

        @logger
      end
    end
  end
end
