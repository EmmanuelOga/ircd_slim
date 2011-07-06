module IRCDSlim
  module Protocol
    module Channel

      def on_join(msg)
        subscribe(msg.client)
      end

      def on_part(msg)
        unsubscribe(msg.client, msg.raw.part_message)
      end

      def on_topic(msg)
        if msg.raw.topic.present?
          # TODO check permissions to change topic
          change_topic(msg)
        else
          reply_topic(msg)
        end
      end

      def on_priv_msg(msg)
        msg.raw.prefix = msg.client.prefix
        msg.black_list(msg.client)
        push(msg)
      end
      alias_method :on_notice, :on_priv_msg

      def on_nick(msg)
        msg.raw.prefix = msg.client.previous_prefix
        msg.black_list(msg.client)
        push(msg)
      end

      def change_topic(msg)
        self.topic = msg.respond_to?(:raw) ? msg.raw.topic : msg.to_s
        reply_topic(msg) if msg.respond_to?(:client)
      end

      def reply_topic(msg)
        if topic.present?
          msg.client.tx(:rpl_topic) do |m|
            m.nick    = msg.client.nick # This probably should be set to the user who set the topic?
            m.channel = name
            m.topic   = topic
          end
        else
          tx(:rpl_no_topic) { |m| m.channel = channel }
        end
      end

      def priv_msg(client, body)
        tx(client, :priv_msg) { |m| m.target = name; m.body = body }
      end

    end
  end
end
