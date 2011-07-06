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

# stopping with a timer: used when running benchmarks
minutes = 0.0
total = 0
MINUTES_TO_RUN = 1

trap("INT") do
  server.stop do
    EventMachine.stop
  end
end

EM.kqueue; EM.epoll

EventMachine.run do
  server.start
  $stderr.puts("ircd server listening on #{server.ip}:#{server.port}")

  root = IRCDSlim::Client.new(:root, "root", `hostname`.chomp, server.port, "root", "127.0.0.1")

  chan = server.channels["#test"].subscribe(root)

  chan.watch do
    total += 1
  end

  sid = chan.watch(:only => [:priv_msg, :notice], :not_from => [root]) do |msg|
    chan.priv_msg(root, "#{msg.client.nick} just said: #{ msg.body }.")
    chan.priv_msg(root, "Here is what #{msg.client.nick} said inverted: #{ msg.body.to_s.reverse }.")
  end

  count = 0

  EM.add_periodic_timer(1) do
    if count == 100
      msg = "Now all again from the sart! #{ count = 1 }"
    else
      msg = "Still counting. Now: #{ count += 1 }"
    end

    chan.priv_msg(root, msg)
  end

  EventMachine::add_periodic_timer( 15 ) do
    $stderr.puts "#{ minutes += 0.25 } minutes elapsed of the total #{ MINUTES_TO_RUN } minute/s runtime."
    server.stop {
      EM.stop
      puts "Received #{total} messages in #{MINUTES_TO_RUN} minutes (#{total/(MINUTES_TO_RUN*60.0)}/sec)."
    } if minutes >= MINUTES_TO_RUN
  end
end
