module IRCDSlim
  module Protocol
    module Server
      include IRCDSlim::Message::ReceiverAPI

      def handle(msg)
        if %w|PASS NICK USER|.include?(msg.identifier) || correct_password?(msg.client)
          super
        else
          tx(msg.client, :err_passwd_mismatch)
        end
      end

      def unhandled_message(msg)
        logger.error(ANSI.red { "  Unhandled Message #{msg.identifier}" })
        tx(msg.client, :err_unknown_command) { |m| m.command = msg.identifier } if msg.client
      end

      def tx(client, identifier, &block)
        raw = IRCParser.message(identifier, prefix, &block)
        msg = IRCDSlim::Message.new(client, raw)
        msg.raw.nick = client.nick if !msg.raw.class.is_command? && msg.raw.respond_to?(:nick) && msg.raw.nick.blank?
        client.handle(msg)
      end

      def on_pass(msg)
        if msg.raw.password.present?
          msg.client.handle(msg)
        else
          tx(msg.client, :err_need_more_params)
        end
      end

      def on_nick(msg)
        if msg.raw.changing? # Think this should be only used in server 2 server
          unhandled_message(msg)

        # TODO
        # elsif ...
        #   tx(client, :err_already_registered)
        #   tx(client, :err_nick_collision)
        #   tx(client, :err_unavail_resource)
        #   tx(client, :err_restricted)

        elsif msg.raw.nick.blank?
          tx(msg.client, :err_no_nick_name_given)

        elsif msg.raw.invalid_nick?
          tx(msg.client, :err_erroneus_nick_name)

        elsif clients.unavailable_nickname?(msg.raw.nick, msg.client)
          tx(msg.client, :err_nick_name_in_use)

        else
          msg.client.nick = msg.raw.nick

          if msg.client.previous_prefix.present?
            tx(msg.client, :nick) do |m|
              m.nick = msg.client.nick
              m.prefix = msg.client.previous_prefix
            end

            channels.joined_by(msg.client).each { |chan| chan.handle(msg) }
          end

          welcome(msg.client)
        end
      end

      def should_welcome?(client)
        valid?(client) && !client.data[:already_welcomed]
      end

      def welcome(client)
        return unless should_welcome?(client)

        tx(client, :rpl_welcome) do |m|
          m.format_postfix :welcome => "Welcome to IRCDSlim@#{prefix}", :user => client.prefix
        end

        tx(client, :rpl_your_host) do |m|
          m.format_postfix :server_name => "IRCDSlim", :version => IRCDSlim::VERSION
        end

        tx(client, :rpl_created) do |m|
          m.format_postfix :date => date
        end

        tx(client, :rpl_my_info) do |m|
          m.server_name = prefix
          m.version = IRCDSlim::VERSION
          m.available_user_modes = "a"
          m.available_channel_modes  = "a"
        end

        tx(client, :rpl_l_user_client) do |m|
          # TODO MODES
          m.format_postfix :users_count => clients.length, :invisible_count => 0, :servers => 1
        end

        tx(client, :rpl_l_user_op) do |m|
          m.operator_count = 1 # TODO Modes
        end

        tx(client, :rpl_l_user_unknown) do |m|
          m.connections = 0
        end

        tx(client, :rpl_l_user_channels) do |m|
          m.channels_count = channels.length
        end

        tx(client, :rpl_l_user_me) do |m|
          m.format_postfix :clients_count => clients.length, :servers_count => 0
        end

        client.data[:already_welcomed] = true
      end

      def tx_motd(client)
        tx(client, :rpl_motd_start) { |m| m.server = prefix }
        motd.split("\n").each { |piece| tx(client, :rpl_motd) { |m| m.motd = piece } }
        tx(msg.client, :rpl_end_of_motd)
      end

      def on_user(msg)
        if msg.raw.user.blank? || msg.raw.realname.blank? || msg.raw.user == "*" || msg.raw.realname == "*"
          tx(msg.client, :err_need_more_params)

        # elsif ...
        # TODO
        # tx(msg.client, :err_already_registered)

        else
          msg.client.handle(msg)
          welcome(msg.client)
        end
      end

      def on_mode(msg)
        #tx(msg.client, :err_chan_o_privs_needed)
        #tx(msg.client, :err_key_set)
        #tx(msg.client, :err_unknown_mode)

        #tx(msg.client, :rpl_ban_list)
        #tx(msg.client, :rpl_end_of_ban_list)

        #tx(msg.client, :rpl_except_list)
        #tx(msg.client, :rpl_end_of_except_list)

        #tx(msg.client, :rpl_invite_list)
        #tx(msg.client, :rpl_end_of_invite_list)

        #tx(msg.client, :rpl_uniq_op_is)

        logger.debug("received flags: #{msg.raw.flags}. Modes are not supported yet.") if msg.raw.flags.present?

        if msg.raw.for_channel?
          on_channel_mode(msg)

        elsif msg.raw.for_user?
          on_user_mode(msg)

        else
          tx(msg.client, :err_need_more_params)
        end
      end

      def on_channel_mode(msg)
        tx(msg.client, :err_no_such_channel) and return unless channels.member?(msg.raw.target)

        chan = channels[msg.raw.target]

        tx(msg.client, :err_no_chan_modes) and return if chan.modeless_channel?

        # We don't change anything since this server
        # does not implement channel modes for now.

        # tx(msg.client, :err_user_not_in_channel)

        # Channel Parameters: <channel> {[+|-]|o|p|s|i|t|n|b|v} [<limit>] [<user>] [<ban mask>]
        tx(msg.client, :rpl_channel_mode_is) do |m|
          m.channel = chan.name
          # m.mode = ""
          # m.mode_params = ""
        end
      end

      def on_user_mode(msg)
        # TODO
        # tx(msg.client, :err_u_mode_unknown_flag)
        # tx(msg.client, :err_users_dont_match)
        client = clients.with_nick(msg.raw.target)

        if client.blank?
          tx(msg.client, :err_no_such_nick)
        else
          tx(msg.client, :rpl_u_mode_is) do |m|
            m.user_nick = msg.client.nick
            m.flags = "+v" # TODO not handling modes right now, everybody can speak!
          end
        end
      end

      def on_quit(msg)
        channels.each { |channel| channel.handle(msg) }
        msg.client.tx("QUIT", msg.client.prefix) { |m| m.quit_message = msg.raw.quit_message }
        clients.delete(msg.client)
      end

      def on_join(msg)
        if msg.raw.channels.empty?
          tx(msg.client, :err_need_more_params)

        elsif msg.raw.channels.any? { |name| IRCParser::Helper.invalid_channel_name?(name) }
          tx(msg.client, :err_no_such_channel)

        # elsif ... tx(msg.client, :err_banned_from_chan)
        # elsif ... tx(msg.client, :err_invite_only_chan)
        # elsif ... tx(msg.client, :err_bad_channel_key)
        # elsif ... tx(msg.client, :err_channel_is_full)
        # elsif ... tx(msg.client, :err_bad_chan_mask)
        # elsif ... tx(msg.client, :err_too_many_channels)

        else
          msg.raw.channels.each { |chan_name| channels[chan_name].handle(msg) }
        end
      end

      def on_part(msg)
        msg.raw.channels.each do |chan_name|
          chan = channels[chan_name]
          chan.handle(msg) if chan
        end
      end

      def on_topic(msg)
        # server_tx(:err_chan_o_privs_needed)
        # server_tx(:err_no_chan_modes)

        tx(msg.client, :err_need_more_params) and return if msg.raw.channel.blank?
        tx(msg.client, :err_not_on_channel) and return if msg.raw.topic.present? && !channels.member?(msg.raw.channel)

        chan = channels[msg.raw.channel]

        if chan
          chan.handle(msg)
        else
          tx(msg.client, :err_no_such_channel)
        end
      end

      def on_list(msg)
        # server_tx(msg.client, :err_no_such_server)

        tx(msg.client, :rpl_list_start)

        channels.each do |chan|
          tx(msg.client, :rpl_list) do |m|
            m.channel   = chan.name
            m.visible   = chan.length
            m.topic     = chan.topic
          end
        end

        tx(msg.client, :rpl_list_end)
      end

      def on_priv_msg(msg)
        # server_tx(msg.client, :err_cannot_send_to_chan)
        # server_tx(msg.client, :err_no_top_level)
        # server_tx(msg.client, :err_wild_top_level)
        # server_tx(msg.client, :err_too_many_targets)
        # server_tx(msg.client, :rpl_away)

        if msg.raw.target.blank?
          tx(msg.client, :err_no_recipient)

        elsif msg.raw.body.blank?
          tx(msg.client, :err_no_text_to_send)

        elsif msg.raw.for_channel?

          if chan = channels[msg.raw.target]
            chan.handle(msg)
          else
            tx(msg.client, :err_no_such_channel)
          end

        elsif msg.raw.for_user?

          if target = clients.with_nick(msg.raw.target)
            msg.raw.prefix = msg.client.prefix
            target.handle(msg)
          else
            tx(msg.client, :err_no_such_nick)
          end

        else
          tx(msg.client, :err_no_recipient) # TODO handle host/server patterns
        end
      end
      alias_method :on_notice, :on_priv_msg

      def on_who(msg)
        if msg.raw.for_channel?
          channels[msg.raw.pattern].handle(msg) if channels.member?(msg.raw.pattern)
        else
          rx = msg.raw.regexp
          clients.select { |cli| cli.prefix =~ rx }.each do |client|
            chan ||= channels.joined_by(client).first
            tx(msg.client, :rpl_who_reply) do |m|
              #m.here!(true) # TODO really handle flags
              m.channel   = chan.name
              m.user      = client.nick #user
              m.host      = client.host
              m.server    = prefix
              m.user_nick = client.nick
              m.format_postfix :hopcount => 1, :realname => "*"
            end if chan
          end
          tx(msg.client, :rpl_end_of_who) { |m| m.pattern = msg.raw.pattern }
        end
      end

      def on_who_is(msg)
        tx(msg.client, :no_nick_name_given) and return if msg.raw.pattern.blank?

        rx = msg.raw.regexp
        clients.each do |client|
          # server_tx(:rpl_away) TODO check away status
          send_whois_reply(msg, client) if client.prefix =~ rx
        end

        tx(msg.client, :rpl_end_of_who_is)
      end

      # http://www.mirc.net/raws/#WHOIS
      def send_whois_reply(msg, client)
        tx(msg.client, :rpl_who_is_user) do |m|
          m.user_nick = client.nick
          m.user = client.user
          m.ip   = client.ip
          m.realname = client.realname.presence || client.nick
        end

        tx(msg.client, :rpl_who_is_channels) do |message|
          message.nick = client.nick
          message.user = client.user
          message.channels = channels.joined_by(client).map(&:name).join(" ")
        end

        tx(msg.client, :rpl_who_is_server) do |message|
          message.nick = client.nick
          message.user = client.user
          message.server = name || "IRCDSlim"
          message.info = "IRCDSlim v#{IRCDSlim::VERSION}"
        end

        # tx(msg.client, :rpl_who_is_operator) do |message|
        #   message.nick
        # end if self.operator?

        # tx(msg.client, :rpl_who_is_idle) do |message|
        #   message.nick = self.nick
        #   message.seconds = self.iddle_time
        # end if self.iddle?
      end

      def on_ping(msg)
        tx(msg.client, :pong) do |m|
          m.server = prefix
        end
      end

      def on_names(msg)
        msg.raw.channels.each { |chan_name| channels[chan_name].handle(msg) if channels.member?(chan_name) }
      end

    end
  end
end
