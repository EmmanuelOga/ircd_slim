module IRCDSlim
  class Message < Struct.new(:client, :raw)

    [:to_s, :identifier, :is_reply?, :is_error?, :to_sym].each do |method|
      class_eval(<<-METHOD, __FILE__, __LINE__)
        def #{method}(*args, &block)
          raw.class.#{method}(*args, &block)
        end
      METHOD
    end

    def initialize(client = nil, raw = nil)
      super
      yield self if block_given?
    end

    HANDLER_NAMES_CACHE = Hash.new { |h, k| h[k] = :"on_#{ k }" }

    def handler_name
      @_handler_name ||= HANDLER_NAMES_CACHE[raw.class.to_sym]
    end

    def raw=(raw)
      self.raw = raw
      @_handler_name = nil # reset handler name
    end

    # this blacklist mechanism is only used on channel fan-out of messages, to avoid
    # clients sending messages to theirselves in an endless loop
    def black_list(client = nil)
      @black_list ||= []
      @black_list << client if client
      @black_list
    end

    def black_listed?(client)
      black_list.include?(client)
    end

    def body
      raw.body if raw.respond_to?(:body)
    end

    def each_line(&block)
      body.split("\n").each(&block) if body.present?
    end

    module ReceiverAPI
      def handle(message)
        if respond_to?(message.handler_name)
          send(message.handler_name, message)
        else
          unhandled_message(message)
        end
      end

      def unhandled_message(message)
        # can be redefined to do something with it (e.g. error reporting)
      end
    end

  end
end
