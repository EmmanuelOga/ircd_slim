# IRCDLocal

IRCDLocal is an irc server which is not really meant to be used as a
full blown irc daemon, but to act as a gateway between different
protocols and an irc client of your choice. In any case if you want to
use it as a simple IRC server without a lot of fancy features, it should
work as expected from an ircd.

Here is an example script to launch a server:

```ruby
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
```
