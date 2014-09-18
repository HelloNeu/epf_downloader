#https://gist.github.com/nilbus/6385142
module EpfDownloader
  module Helpers
    module Format
      def number_with_delimiter(number)
        number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      end
    end

    class Callbacks
      def initialize(block, *args)
        block.call(*[self, *args])

        @callbacks = {}
      end

      def call(message, *args)
        @callbacks[message].call(*args) if @callbacks[message]
      end

      def responds_to? (message)
        @callbacks.include? message
      end

      def method_missing(m, *args, &block)
        block ? @callbacks[m] = block : super
        self
      end
    end
  end
end