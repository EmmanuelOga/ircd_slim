module IRCDSlim
  class Server
    class Channels

      def initialize(server)
        @server = server
        @channels = Hash.new { |hash, name| hash[name] = IRCDSlim::Channel.new(@server, name) }
      end

      def names
        @channels.keys
      end

      def get(name)
        @channels[name]
      end
      alias_method :[], :get

      def joined_by(client)
        @channels.values.select { |chan| chan.member?(client) }
      end

      def length
        @channels.length
      end
      alias_method :count, :length

      def member?(name)
        @channels.member?(name)
      end

      def each(&block)
        @channels.values.each(&block)
      end

      def unsubscribe(client)
        each { |chan| chan.unsubscribe(client) }
      end

      def release_if_empty(channel)
        chan = channel.is_a?(IRCDSlim::Channel) ? channel : get(channel.to_s)
        @channels.delete(chan.name) if chan && chan.empty?
      end

    end
  end
end
