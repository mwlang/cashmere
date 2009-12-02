require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Authenticator::MockAuth do
  
  it "should be useable" do 
    Authenticator.authenticators.should == []
    Authenticator.use :MockAuth, {"mwlang" => "mwlang", "demo" => "secret"}
    Authenticator.authenticators.should == [Authenticator::MockAuth]
  end
  
  it "should have two users" do
    Authenticator.user_exists?("mwlang").should == true
    Authenticator.user_exists?("demo").should == true
  end
    
  it "should authenticate the users" do 
    Authenticator.authenticate("mwlang", "mwlang").should == true
    Authenticator.authenticate("demo", "secret").should == true
  end
  
  it "should not authenticate incorrect credentials" do 
    Authenticator.authenticate("mwlang", "secret").should == false
    Authenticator.authenticate("sorry", "charlie").should == false
  end
  
  it "should be reuseable" do
    Authenticator.use :MockAuth, {"scooby" => "doo", "scrappy" => "too"}
    Authenticator.authenticators.should == [Authenticator::MockAuth]
    Authenticator.authenticate("mwlang", "mwlang").should == false
    Authenticator.authenticate("demo", "secret").should == false
    Authenticator.authenticate("scooby", "doo").should == true
    Authenticator.authenticate("scrappy", "too").should == true    
  end
end
