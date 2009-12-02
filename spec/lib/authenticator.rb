require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Authenticator do
  
  it "should not have any Authenticators registered" do 
    Authenticator.authenticators.should == []
  end
  
end
