# Requiring this file is an quick way to run an ircd
# This server configuration is used when running the features
# (server run in a different process)
require 'ircd_slim'

server = IRCDSlim::Server.new do |server|
  server.prefix = `hostname`.chomp
  server.date = Time.now
  server.motd = "Welcome!"
  server.port = ENV["ircd_port"] || 10000
end

trap("INT") do
  server.stop do
    EventMachine.stop
  end
end

EventMachine.run do
  server.start
  $stderr.puts("ircd server listening on #{server.ip}:#{server.port}")

  root = IRCDSlim::Client.new(:root, "root", `hostname`.chomp, server.port, "root", "127.0.0.1")

  chan = server.channels["#test"].subscribe(root)

  sid = chan.watch(:only => [:priv_msg, :notice], :not_from => [root]) do |msg|
    chan.priv_msg(root, "#{msg.client.nick} just said: #{ msg.body }.")
    chan.priv_msg(root, "Here is what #{msg.client.nick} said inverted: #{ msg.body.to_s.reverse }.")
  end
end
