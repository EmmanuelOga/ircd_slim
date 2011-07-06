Given /^(\w+) establish(?:es)? a connection$/ do |who|
  clients[who] # syntactic sugar
end

Given /^(\w+) registered as user "([^"]*)" with nick "([^"]*)"$/ do |who, user_with_host, nick|
  clients[who].message("USER") { |msg| msg.user, msg.prefix = user_with_host.split("@"); msg.realname = "Johnny" }
  clients[who].message("NICK") { |msg| msg.nick = nick }
end
