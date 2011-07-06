require 'spec_helper'

describe IRCDSlim::Message do

  it "holds a black list" do
    subject.black_list(:something)
    subject.black_listed?(:something).should be_true
    subject.black_listed?(:something_else).should_not be_true
  end

end
