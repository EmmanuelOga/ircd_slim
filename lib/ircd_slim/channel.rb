module IRCDSlim
  class Channel < Struct.new(:server, :name, :topic, :watcher, :channel, :subscriptions)
    include IRCDSlim::Protocol::Channel

    include IRCDSlim::Message::ReceiverAPI

    # If we don't need to do anything special to with the message, just push it to the clients
    def unhandled_message(msg)
      msg.raw.prefix = msg.client.prefix
      push(msg)
    end

    alias_method :to_s, :name
    include IRCParser::Helper::Channel

    attr_accessor :release_if_empty

    def initialize(server, name, topic = nil, mode = "")
      raise ArgumentError if name.blank?
      self.release_if_empty = true
      super(server, name, topic || "Welcome to #{name}", EM::Channel.new, EM::Channel.new, Hash.new)
    end

    private :watcher=, :channel=, :subscriptions=

    def length
      subscriptions.length
    end

    def empty?
      subscriptions.empty?
    end

    def clients
      subscriptions.keys
    end

    def member?(client)
      clients.include?(client)
    end

    def nicks
      clients.map { |c| c.nick if c.respond_to?(:nick) }.compact
    end

    def subscribe(client)
      unless member?(client)
        subscriptions[client] = channel.subscribe(client) { |msg|
          client.handle(msg) unless msg.black_listed?(client)
        }

        tx(client, :join) do |m|
          m.prefix = client.prefix
          m.channels = name
        end
      end
      self
    end

    def unsubscribe(client, part_message = "")
      if member?(client) && client.is_a?(IRCDSlim::Client)
        tx(client, :part) do |m|
          m.prefix = client.prefix
          m.channels = name
          m.part_message = part_message.blank? ? client.nick : part_message
        end
      end

      channel.unsubscribe(subscriptions[client])
      subscriptions.delete(client)

      server.channels.release_if_empty(self) if self.release_if_empty

      self
    end

    def push(msg)
      watcher.push(msg); channel.push(msg)
    end

    def watch(options = {}, &callback)
      filter = Filter.new(options)
      watcher.subscribe { |msg| callback.call(msg) if filter.allow?(msg) }
    end

    def unwatch(sid)
      watcher.unsubscribe(sid)
    end

    def tx(client, identifier, &block)
      raw = IRCParser.message(identifier, client.prefix, &block)
      msg = IRCDSlim::Message.new(client, raw)
      push(msg)
    end

    class Filter
      def initialize(options = {})
        [:only, :except, :from, :not_from].each {|key| instance_variable_set("@#{key}", Array(options[key])) if options[key] }
      end

      def block?(msg)
        (@except && @except.include?(msg.to_sym))     ||
        (@only && !@only.include?(msg.to_sym))        ||
        (@not_from && @not_from.include?(msg.client)) ||
        (@from && !@from.include?(msg.client))
      end

      def allow?(msg)
        not block?(msg)
      end
    end
  end
end
