module IRCDSlim
  module Protocol
    module Client

      def on_user(msg)
        return unless msg.client == self
        self.user = msg.raw.user
        self.realname = msg.raw.realname
      end

      def on_pass(msg)
        return unless msg.client == self
        self.password = msg.raw.password
      end

    end
  end
end
