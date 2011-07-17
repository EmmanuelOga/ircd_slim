module IRCDSlim
  module Protocol
    module Channel

#:rpl_channel_mode_is   >> :sendak.freenode.net 324 emmanuel #pipita2 +ns
#:rpl_channel_timestamp >> :sendak.freenode.net 329 emmanuel #pipita2 1310887741

#:rpl_who_reply         >> :sendak.freenode.net 352 emmanuel #pipita2 ~emmanuel 190.244.29.19 sendak.freenode.net emmanuel H@ :0 Unknown
#:rpl_end_of_who        >> :sendak.freenode.net 315 emmanuel #pipita2 :End of /WHO list.

      def on_join(msg)
        subscribe(msg.client); on_who(msg); on_names(msg); on_topic(msg)
        # TODO add message 333 ? (topic date)
        tx(msg.client, :mode) do |m|
          m.prefix = server.prefix
          m.target = name
          m.user = "*" # who created the channel? Need to review the rfc.
          m.positive_flags!
          m.chan_speaker!
        end
      end

      def on_who(msg)
        clients.each do |client|
          tx(msg.client, :rpl_who_reply) do |m|
            #m.here!(true) # TODO really handle flags
            m.channel   = name
            m.user      = client.nick #user
            m.host      = client.host
            m.server    = server.prefix
            m.user_nick = client.nick
            m.hopcount  = 1
            m.realname  = "*"
          end
        end

        tx(msg.client, :rpl_end_of_who) { |m| m.pattern = name }
      end

      def on_names(msg)
        tx(msg.client, :rpl_nam_reply)    { |m| m.channel, m.nicks_with_flags = name, nicks.join(" ") }
        tx(msg.client, :rpl_end_of_names) { |m| m.channel = name }
      end

      def on_part(msg)
        unsubscribe(msg.client, msg.raw.part_message)
      end

      def on_topic(msg)
        if msg.raw.respond_to?(:topic) && msg.raw.topic.present?
          change_topic(msg) # TODO check permissions to change topic
        else
          reply_topic(msg)
        end
      end

      def on_priv_msg(msg)
        unless member?(msg)
          subscribe(msg.client); on_names(msg); on_who(msg)
        end
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
          msg.client.tx(:rpl_topic) { |m| m.channel, m.topic = name, topic }
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
