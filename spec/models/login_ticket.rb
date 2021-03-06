=begin

    * Login tickets issued by /login MUST be probabilistically unique.

    * Login tickets MUST only be valid for one authentication attempt. Whether or not authentication was successful,
      CAS MUST then invalidate the login ticket, causing all future authentication attempts with that instance of
      that login ticket to fail.

    * Login tickets SHOULD begin with the characters, "LT-".
  
=end

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe LoginTicket do
  
  it "should initialize" do 
    ticket = LoginTicket.new('http://cybrains.net')
    ticket.should.not == nil
    ticket.service.should.not == nil
  end

  describe "login ticket properties" do
    
    describe "unvalidated login ticket" do
      it "should have a short lifespan" do
        ticket = LoginTicket.new('http://cybrains.net')
        ticket.created_at -= 6 * 60 # five minutes
        ticket.save
        
        bad_ticket = LoginTicket.find(ticket.ticket, ticket.service)
        bad_ticket.valid?.should == false
      end
    end
    
    describe "ticket number" do
      ticket = LoginTicket.new('http://cybrains.net')

      it "should start with LT-" do
        ticket.ticket.should =~ /^LT-[a-zA-Z0-9\-]*$/
      end

    end
        
    it "is only valid once!" do 
      new_ticket = LoginTicket.new('http://cybrains.net').save
      good_ticket = LoginTicket.find(new_ticket.ticket, new_ticket.service)
      bad_ticket = LoginTicket.find(new_ticket.ticket, new_ticket.service)
      good_ticket.valid?.should == true
      bad_ticket.should == nil
    end
    
    it "is never valid if service identifiers don't match" do
      new_ticket = LoginTicket.create('http://cybrains.net')
      bad_ticket = LoginTicket.find(new_ticket.ticket, 'http://www.cybrains.net')
      bad_ticket.valid?.should == false
    end
    
  end
end
