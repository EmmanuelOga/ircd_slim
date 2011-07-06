RSpec::Matchers.define :include_message_with do |attributes|

  match do |messages|
    result = Array(messages).detect do |msg|

      attributes.all? do |attr, expected|
        Array(msg.send(attr)).detect { |returned| expected === returned }
      end

    end
  end

  failure_message_for_should do |messages|
    error_for_messages "No one of the following messages matched #{attributes.inspect}:", messages
  end

  failure_message_for_should_not do |messages|
    error_for_messages "One of the following messages matched #{attributes.inspect}:", messages
  end

  description do
    "One or more from the received messages matches the expected attributes"
  end

  def error_for_messages(prefix, messages)
    if Array(messages).empty?
      "Expected to receive messages but did not received anything"
    else
      "#{prefix}\n#{Array(messages).map {|str| "  #{str.to_s.chomp}" }.join("\n")}"
    end
  end
end
