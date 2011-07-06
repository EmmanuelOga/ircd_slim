# Requiring this file is an quick way to run an ircd
# This server configuration is used when running the features
# (server run in a different process)
require 'ircd_slim'

server = IRCDSlim::Server.new do |server|
  server.prefix = `hostname`.chomp
  server.date = Time.now
  server.motd = "Welcome!"
  server.port = $ircd_port || 10000
  server.logger = Logger.new File.join(File.dirname(__FILE__), "../../../log/development.log")
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
