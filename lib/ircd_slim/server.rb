module IRCDSlim
  class Server < Struct.new(:prefix, :name, :date, :motd, :port, :ip, :logger, :listener, :clients, :channels, :password)
    include IRCDSlim::Protocol::Server

    def initialize(prefix = nil, name = nil, date = nil, motd = nil, port = nil, ip = nil, logger = nil)
      super
      self.ip ||= '0.0.0.0'
      self.port ||= 10000
      self.clients = IRCDSlim::Server::Clients.new(self)
      self.channels = IRCDSlim::Server::Channels.new(self)
      yield self if block_given?
      self.logger = Logger.new(STDOUT) unless self.logger
    end

    private :listener=, :clients=, :channels=

    autoload :Clients,  "ircd_slim/server/clients"
    autoload :Channels, "ircd_slim/server/channels"

    def start
      raise RuntimeError, "the server can only listen to a single ip:port right now" if listener
      self.listener = IRCDSlim::Network::Listener.new(self, port, ip)
      listener.start
    end

    def stop(&callback)
      listener.stop(&callback)
    end

    def correct_password?(client)
      !password_required?(client) || password_accepted?(client)
    end

    def password_required?(client)
      password.present? # TODO: per user password. Right now a single password is used to check any user.
    end

    def password_accepted?(client)
      password.blank? || client.password == password
    end

    def valid?(client)
      client.registered? && correct_password?(client)
    end
  end
end
