require 'spec_helper'

describe IRCDSlim::Client do
  before do
    @client = IRCDSlim::Client.new
    @client.user = "Emmanuel"
    @client.host = "goingmerry"
    @client.nick = "eoga"
  end

  it "becomes registered only when both user host and nick are present" do
    @client.dup.tap { |c| c.nick = "" }.should_not be_registered
    @client.dup.tap { |c| c.user = "" }.should_not be_registered
    @client.dup.tap { |c| c.host = "" }.should_not be_registered
    @client.should be_registered
  end

  it "returns a prefix according the user host, nick and user" do
    @client.prefix.should == "eoga!Emmanuel@goingmerry"
  end

  it "returns blank for previous prefix if there isn't one" do
    @client.previous_prefix.should be_blank
  end

  it "remembers the previous prefix on a nick change" do
    @client.nick = "new_nick"
    @client.previous_prefix.should == "eoga!Emmanuel@goingmerry"
    @client.prefix.should == "new_nick!Emmanuel@goingmerry"
  end
end

