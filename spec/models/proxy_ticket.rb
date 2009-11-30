=begin

    * Proxy tickets are only valid for the service identifier specified to /proxy when they were generated. The service
      identifier SHOULD NOT be part of the proxy ticket.

    * Proxy tickets MUST only be valid for one ticket validation attempt. Whether or not validation was successful, CAS
      MUST then invalidate the ticket, causing all future validation attempts of that same ticket to fail.

    * CAS SHOULD expire unvalidated proxy tickets in a reasonable period of time after they are issued. If a service
      presents for validation an expired proxy ticket, CAS MUST respond with a validation failure response. It is
      RECOMMENDED that the validation response include a descriptive message explaining why validation failed. It is
      RECOMMENDED that the duration a proxy ticket is valid before it expires be no longer than five minutes. Local
      security and CAS usage considerations MAY determine the optimal lifespan of unvalidated proxy tickets.

    * Proxy tickets MUST contain adequate secure random data so that a ticket is not guessable.

    * Proxy tickets SHOULD begin with the characters, "PT-". Proxy tickets MUST begin with either the characters, "ST-" or
      "PT-".

    * Back-end services MUST be able to accept proxy tickets of up to 32 characters in length. It is RECOMMENDED that
      back-end services support proxy tickets of up to 256 characters in length.
  
=end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe ProxyTicket do
  
  it "should initialize" do 
    ticket = ProxyTicket.new('http://cybrains.net')
    ticket.should.not == nil
    ticket.service.should.not == nil
  end

  describe "3.2.1. proxy ticket properties" do
    
    describe "unvalidated proxy ticket" do
      it "should have a short lifespan" do
        ticket = ProxyTicket.new('http://cybrains.net')
        ticket.created_at -= 6 * 60 # five minutes
        ticket.save
        
        bad_ticket = ProxyTicket.find(ticket.ticket, ticket.service)
        bad_ticket.valid?.should == false
      end
    end
    
    describe "ticket number" do
      ticket = ProxyTicket.new('http://cybrains.net')

      it "should start with PT-" do
        ticket.ticket.should =~ /^PT-[a-zA-Z0-9\-]*$/
      end

      it "should contain only [a..z, A..Z, 0..9, -]" do
        ticket.ticket.should =~ /^[a-zA-Z0-9\-]*$/
      end
    
      it "should be sufficiently long" do 
        ticket.ticket.size.should > 32
      end
    end
    
  end
end
