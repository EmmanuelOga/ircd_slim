module IRCDSlim
  class Server

    class Clients
      def initialize(server)
        @server, @clients = server, []
      end

      def with_nick(nick)
        @clients.detect { |client| client.nick == nick }
      end

      def nicknamed?(nick)
        with_nick(nick).present?
      end

      def unavailable_nickname?(nick, client)
        cli = with_nick(nick)
        cli.present? && cli != client
      end

      def delete(client)
        @server.channels.unsubscribe(client)
        client.disconnect
        @clients.delete(client)
      end

      def push(client)
        @clients << client unless @clients.include?(client) # Rather not use a Set for now
      end

      [:each, :select, :length, :include?].each do |method|
        class_eval(<<-METHOD, __FILE__, __LINE__)
          def #{method}(*args, &block)
            @clients.#{method}(*args, &block)
          end
        METHOD
      end

      alias_method :<<, :push
    end

  end
end

