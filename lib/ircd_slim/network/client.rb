module IRCDSlim
  module Network
    class Client < IRCDSlim::Client
      attr_accessor :connection

      def send_data(data)
        connection.send_data(data)
      end

      def disconnect
        connection.close_connection_after_writing
      end

      # Normally, the server send the Client replies or errors,
      # we don't need to handle in any special way but
      # just tx the msg to the other side.
      def unhandled_message(message)
        send_data(message.raw) if message.raw
        self
      end

    end
  end
end
