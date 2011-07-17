module IRCDSlim
  module Network
    module Connection
      include EventMachine::Protocols::LineText2

      module Base
        attr_accessor :server, :listener, :client, :ip, :port

        def logger
          @server.logger
        end

        def log_exception(error)
          logger.error(ANSI.red { "  #{error}" })
          error.backtrace.each { |line| logger.error(ANSI.red { "    --> #{ line }" }) }
        end

        def configure(server, listener)
          @port, @ip = Socket.unpack_sockaddr_in(get_peername)
          @server, @listener = server, listener

          set_delimiter("\r\n")

          @client = IRCDSlim::Network::Client.new
          @client.connection = self
          @client.ip = ip
          @client.host = ip
          @client.port = port

          @server.clients << client

          self
        end

        def receive_line(line)
          line.split(/\r?\n/).each do |l|
            begin
              @server.handle(IRCDSlim::Message.new(@client, IRCParser.parse("#{l}\r\n")))
            rescue => error
              log_exception(error)
              @server.tx(@client, :err_unknown_command) { |m| m.command = line }
            end
          end
        end

        def unbind
          super
          @server.clients.delete(@client)
          @listener.unbind(self)
        end
      end

      module Logging
        def send_data(data)
          logger.debug("#{ ANSI.green { "SND" } }  to  #{identity}: #{data.to_s.inspect}")
          super
        end

        def receive_line(line)
          logger.debug("#{ ANSI.yellow { "RCV" } } from #{identity}: #{line.inspect}")
          super
        rescue => error
          log_exception(error)
        end

        def identity
          if @client.nick.blank?
            "#{ANSI.cyan{ @ip }}:#{ ANSI.cyan { @port } }"
          else
            ANSI.blue { @client.nick.to_s.ljust(15) }
          end
        end
      end

      include Base
      include Logging
    end
  end
end
