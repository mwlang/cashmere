=begin
Service tickets are only valid for the service identifier that was specified to /login when they were generated. 

The service identifier SHOULD NOT be part of the service ticket.

Service tickets MUST only be valid for one ticket validation attempt. 

Whether or not validation was successful, CAS MUST then invalidate the ticket

CAS SHOULD expire unvalidated service tickets in a reasonable period of time after they are issued. 

If a service presents for validation an expired service ticket, CAS MUST respond with a validation failure response. 

Service tickets MUST contain adequate secure random data so that a ticket is not guessable.

Service tickets MUST begin with the characters, "ST-".

Services MUST be able to accept service tickets of up to 32 characters in length. 
=end


require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe ServiceTicket do
  
  it "should initialize" do 
    ticket = ServiceTicket.new('http://cybrains.net')
    ticket.should.not == nil
    ticket.service.should.not == nil
  end

  describe "3.1.1. service ticket properties" do
    
    describe "unvalidated service ticket" do
      it "should have a short lifespan" do
        ticket = ServiceTicket.new('http://cybrains.net')
        ticket.created_at -= 6 * 60 # five minutes
        ticket.save
        
        bad_ticket = ServiceTicket.find(ticket.ticket, ticket.service)
        bad_ticket.valid?.should == false
      end
    end
    
    describe "ticket number" do
      ticket = ServiceTicket.new('http://cybrains.net')

      it "should start with ST-" do
        ticket.ticket.should =~ /^ST-[a-zA-Z0-9\-]*$/
      end

      it "should contain only [a..z, A..Z, 0..9, -]" do
        ticket.ticket.should =~ /ST-[a-zA-Z0-9\-]*$/
      end
    
      it "should be sufficiently long" do 
        ticket.ticket.size.should > 32
      end
    end

    it "should save to database when created" do 
      new_ticket = ServiceTicket.create('http://cybrains.net')
      good_ticket = ServiceTicket.find(new_ticket.ticket)
      good_ticket.should.not == nil
    end
    
    it "should keep requesting service when supplied" do 
      new_ticket = ServiceTicket.create('http://cybrains.net')
      new_ticket.service.should == 'http://cybrains.net'
      good_ticket = ServiceTicket.find(new_ticket.ticket, new_ticket.service)
      good_ticket.should.not == nil
      good_ticket.service.should == 'http://cybrains.net'
    end
    
    describe "service identifier" do 
      
      it "must match what was specified to /login" do
        new_ticket = ServiceTicket.new('http://cybrains.net').save
        good_ticket = ServiceTicket.find(new_ticket.ticket, new_ticket.service)
        good_ticket.valid?.should == true

        new_ticket = ServiceTicket.create('http://cybrains.net')
        bad_ticket = ServiceTicket.find(new_ticket.ticket, 'http://notme.com')
        bad_ticket.is_a?(ServiceTicket).should == true
        bad_ticket.service.should == 'http://cybrains.net'
        bad_ticket.requesting_service.should == 'http://notme.com'
        bad_ticket.valid?.should == false
      end
        
      it "a blank service should be valid" do
        new_ticket = ServiceTicket.create
        good_ticket = ServiceTicket.find(new_ticket.ticket)
        good_ticket.valid?.should == true

        new_ticket = ServiceTicket.create
        good_ticket = ServiceTicket.find(new_ticket.ticket, new_ticket.service)
        good_ticket.valid?.should == true
      end
        
      it "is only valid once!" do 
        new_ticket = ServiceTicket.create('http://cybrains.net')
        good_ticket = ServiceTicket.find(new_ticket.ticket, new_ticket.service)
        bad_ticket = ServiceTicket.find(new_ticket.ticket, new_ticket.service)
        good_ticket.valid?.should == true
        bad_ticket.should == nil
      end
      
      it "is never valid if service identifiers don't match" do
        new_ticket = ServiceTicket.new('http://cybrains.net').save
        bad_ticket = ServiceTicket.find(new_ticket.ticket, 'http://www.cybrains.net')
        bad_ticket.should.not == nil
        bad_ticket.valid?.should == false
      end
    end
    
  end
end
