class BasicServer
  def self.start
    server = IRCDSlim::Server.new do |server|
      server.prefix = `hostname`.chomp
      server.date = Time.now
      server.motd = "Welcome!"
      server.port = $ircd_port || 10000
      server.logger = Logger.new "log/development.log"
    end

    trap("INT") do
      server.stop do
        EventMachine.stop
      end
    end

    EventMachine.run do
      $stderr.puts "Starting server at localhost:#{server.port}"
      server.start
    end
  end
end
