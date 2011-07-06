require 'spec_helper'

describe IRCDSlim::Server::Clients do
  before do
    @server = IRCDSlim::Server.new
    @clients = @server.clients

    @client1 = IRCDSlim::Client.new "EmmanuelOga", "emmanuel", "127.0.0.1", 59631, "s3cr3t", "Emmanuel"
    @client2 = IRCDSlim::Client.new nil,           "emmanuel", "127.0.0.1", 59632, nil,      "Emmanuel"

    @clients << @client1 << @client2
  end

  it "is able to remove clients from the set" do
    @clients.delete(@client1)
    @clients.should_not include(@client1)
    @clients.length.should == 1
  end

  it "knows if there is there is a client with some nick" do
    @clients.nicknamed?("tony").should be_false
    @clients.nicknamed?("EmmanuelOga").should be_true
  end

  it "unsubscribes clients from channels when the client is removed. The channel is released when empty" do
    @server.channels.get("#test").should be_empty

    @server.channels.get("#test").subscribe(@client1)
    @server.channels.get("#test").subscribe(@client2)

    @server.channels.get("#test").length.should == 2

    @clients.delete(@client1)

    @server.channels.get("#test").length.should == 1
    @server.channels.member?("#test").should be_true

    @clients.delete(@client2)

    @server.channels.member?("#test").should be_false
    @server.channels.get("#test").length.should == 0
  end

end
