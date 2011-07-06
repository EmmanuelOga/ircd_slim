module IRCDSlim
  class Client < Struct.new(:nick, :user, :host, :port, :password, :realname, :ip)
    include IRCDSlim::Message::ReceiverAPI
    include IRCDSlim::Protocol::Client

    def self.sanitize_nick(nick)
      nick.to_s.gsub(/[^a-zA-Z0-9\-_]/, "")
    end

    def data
      @data ||= Hash.new
    end

    def is_user?(user, host)
      self.user == user && self.host == host
    end

    def user=(user)
      @_prefix = nil; super
    end

    def host=(host)
      @_prefix = nil; super
    end

    def nick=(new_nick)
      @_prefix, @previous_nick = nil, nick
      super(self.class.sanitize_nick(new_nick))
    end

    def nick_changed?
      @previous_nick.present? && @previous_nick != @nick
    end

    def operator?
      false # TODO implement real modes
    end

    def invisible?
      false # TODO implement real modes
    end

    def registered?
      host.present? && nick.present? && user.present?
    end

    def prefix
      @_prefix ||= "#{nick}!#{user}@#{host}"
    end

    def previous_prefix
      "#{@previous_nick}!#{user}@#{host}" if @previous_nick
    end

    def disconnect
      # do something on disconnect (e.g. network clients might want to unbind socket)
    end

    def tx(identifier, prefix_param = nil, &block)
      send_data(IRCParser.message(identifier, prefix_param || prefix, &block))
    end

    def send_data(data)
      # actually write the IRC message in string form to the destination.
    end

  end
end
