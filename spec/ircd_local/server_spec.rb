require 'spec_helper'

describe IRCDSlim::Server do

  it "returns a channel with the right name and topic" do
    subject.channels["#some_channel"].name.should == "#some_channel"
    subject.channels["#some_channel"].topic.should == "Welcome to #some_channel"
    subject.channels["&some_other_channel"].name.should == "&some_other_channel"
    subject.channels["&some_other_channel"].topic.should == "Welcome to &some_other_channel"
  end

  it "does not validate passwords for now" do
    subject.correct_password?(IRCDSlim::Client.new).should be_true
    subject.password_required?(IRCDSlim::Client.new).should be_false
    subject.password_accepted?(IRCDSlim::Client.new).should be_true
  end

  it "provides a logger by default" do
    subject.logger.should respond_to(:info)
    subject.logger.should respond_to(:error)
    subject.logger.should respond_to(:debug)
  end

  it "holds a collection of clients" do
    subject.clients.should respond_to(:each)
  end

  it "holds a collection of channels" do
    subject.channels.should respond_to(:each)
  end

  it "can initialize the network listener" do
    EM.run do
      expect { subject.start }.to change(subject, :listener).from(nil).to(instance_of(IRCDSlim::Network::Listener))
      subject.stop do
        EM.stop
      end
    end
  end

  it "knows when a client is valid" do
    client = mock("Client")
    client.stub!(:registered?).and_return(false)
    subject.stub!(:correct_password).with(client).and_return(true)
    subject.valid?(client).should be_false
    client.stub!(:registered?).and_return(true)
    subject.valid?(client).should be_true
  end

end
