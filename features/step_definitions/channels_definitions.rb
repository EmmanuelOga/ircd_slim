Given /^(\w+) JOINs? "([^"]*)"$/ do |who, chan|
  Given "#{who} send \"JOIN\" with:", table(%{ | channels | #{chan} | })
end
