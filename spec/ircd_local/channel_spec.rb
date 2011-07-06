require 'spec_helper'

describe IRCDSlim::Channel do
  subject do
    IRCDSlim::Channel.new(IRCDSlim::Server.new, "#some_channel")
  end

  it "knows its name" do
    subject.name.should == "#some_channel"
  end

  it "raises argument error when a bad name is provided" do
    expect { IRCDSlim::Channel.new(" *** ") }.to raise_error
  end

  it "infers it is local from the name of the channel" do
    subject.name = "&hola"
    subject.should be_local_channel
    subject.name = "#hola"
    subject.should_not be_local_channel
  end

  it "initializes the topic from the name of the channel" do
    subject.topic.should == "Welcome to #some_channel"
  end

  it "allows changing the topic through an IRC message" do
    subject.change_topic(IRCDSlim::Message.new(IRCDSlim::Client.new, IRCParser.message(:topic) { |m| m.topic = "New Topic" }))
    subject.topic.should == "New Topic"
  end

  it "allows changing the topic through an string" do
    subject.change_topic("New Topic")
    subject.topic.should == "New Topic"
  end
end
