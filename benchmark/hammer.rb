$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../../irc_parser/lib")))

require File.expand_path(File.join(File.dirname(__FILE__), "../features/support/irc_client"))

# This is script with hammer down an irc server with random crap
# Used to profile the ircd.
CLIENTS = 50
MINUTES = 5

threads = []

1.upto(CLIENTS) do |number|
  threads << Thread.new(number) do |n|

    nick, user = "Client#{n}", "User#{n}"

    client = IRCClient.new(nick, 10000)

    client.message("NICK") do |m|
      m.nick = nick
    end

    client.message("USER") do |m|
      m.user = nick
      m.realname = user
    end

    client.message("JOIN") do |m|
      m.channels = "#test"
    end

    client.received_messages("JOIN", true)

    start = Time.now

    loop do
      (rand(2) + 1).times do
        client.message("PRIVMSG") do |m|
          m.body = (0..(5 + rand(10))).map { rand(123123).to_s(36) }.join("")
          m.target = "#test"
        end
        sleep(1) if rand(2) == 1
      end

      break if ((Time.now - start) / 60) > MINUTES
    end

  end
end

threads.each { |thread| thread.join }
