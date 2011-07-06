When /^(\w+) sends? a not defined message "([^"]*)"$/ do |who, string|
  clients[who].send_raw(string)
end

When /^(\w+) sends? "([^"]*)"$/ do |who, name|
  clients[who].message(name)
end

When /^(\w+) sends? "([^"]*)" with:$/ do |who, name, table|
  clients[who].message(name) do |msg|
    table.raw.each do |method, value|
      val = parse_value(value)

      if method =~ /\!$/
        val.present? ? msg.send(method, val) : msg.send(method)
      elsif val.present?
        msg.send("#{method}=", val)
      end
    end
  end
end

Then /^(\w+) should not receive any message$/ do |who|
  clients[who].number_of_received_messages.should == 0
end

Then /^(\w+) should not receive "([^"]*)"$/ do |who, name|
  clients[who].received_messages(name, true).should be_empty
end

# message

Then /^(\w+) should\s*(not)? receive "([^"]*)" with:$/ do |who, no, name, table|
  attrs = Hash[table.raw.map { |(name, val)| [name, parse_value(val)]}]
  messages = clients[who].received_messages(name, true)
  messages.send(no ? :should_not : :should, include_message_with(attrs))
end

Then /^(\w+) should receive "([^"]*)"$/ do |who, name|
  clients[who].received_messages(name, true).should_not be_empty
end

Then /^(\w+) should receive messages "([^"]*)" through "([^"]*)"$/ do |who, start, finish|
  clients[who].received_messages(nil, true).map { |msg| msg.class.identifier }.should include(*(start..finish).to_a)
end
