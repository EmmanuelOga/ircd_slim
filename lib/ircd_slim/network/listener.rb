module IRCDSlim
  module Network
    class Listener
      attr_reader :connections, :server, :port, :ip, :connections

      def logger
        server.logger
      end

      def initialize(server, port = 10000, ip = '0.0.0.0')
        @server, @port, @ip, @connections = server, port, ip, []
      end

      def start
        @signature = EventMachine.start_server(ip, port, IRCDSlim::Network::Connection, &method(:configure))
      end

      def stop(&callback)
        EventMachine.stop_server(@signature)

        unless wait_for_connections_and_stop(&callback)
          EventMachine.add_periodic_timer(0.5) { wait_for_connections_and_stop(&callback) }
        end
      end

      def unbind(connection)
        connections.delete(connection)
      end

      def configure(conn)
        conn.configure(server, self); connections.push(conn)
      end
      private :configure

      def wait_for_connections_and_stop(&callback)
        if connections.empty?
          callback.call(self)
          true
        else
          logger.info("Still #{connections.length} connection/s to shutdown.")
          connections.each { |conn| conn.close_connection_after_writing }
          false
        end
      end
      private :wait_for_connections_and_stop

      module Logging
        def start
          logger.info("-" * 80)
          logger.info(ANSI.magenta { "Starting IRC daemon at #{ip}:#{port}" })
          logger.info("-" * 80)
          super
        end

        def stop(&callback)
          logger.info("Stopping IRC daemon")
          super
        end

        def unbind(connection)
          if super
            logger.info "Client disconnected. #{ connections.length } connections left. #{ server.clients.length } clients left."
          end
        end

        def configure(conn)
          super
          logger.info "New client connected. Now handling #{connections.length} network connections."
        end

        def wait_for_connections_and_stop(&callback)
          result = super
          logger.info("Still #{connections.length} connection/s to shutdown.") unless result
          result
        end
      end

      include Logging
    end
  end
end
