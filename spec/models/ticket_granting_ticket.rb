
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe TicketGrantingTicket do
  
  it "should initialize" do 
    ticket = TicketGrantingTicket.new('snoopy')
    ticket.should.not == nil
    ticket.username.should.not == nil
  end

  describe "ticket granting ticket properties" do
    
    describe "ticket number" do
      ticket = TicketGrantingTicket.new('snoopy')

      it "should start with TGC-" do
        ticket.ticket.should =~ /^TGC-[a-zA-Z0-9\-]*$/
      end

      it "should contain only [a..z, A..Z, 0..9, -]" do
        ticket.ticket.should =~ /TGC-[a-zA-Z0-9\-]*$/
      end
    
      it "should be sufficiently long" do 
        ticket.ticket.size.should > 32
      end
    end

    it "should save to database when created" do 
      new_ticket = TicketGrantingTicket.create('snoopy')
      good_ticket = TicketGrantingTicket.find(new_ticket.ticket)
      good_ticket.should.not == nil
    end
    
    it "should keep username when supplied" do 
      new_ticket = TicketGrantingTicket.create('snoopy')
      new_ticket.username.should == 'snoopy'
      good_ticket = TicketGrantingTicket.find(new_ticket.ticket)
      good_ticket.should.not == nil
      good_ticket.username.should == 'snoopy'
    end
        
  end
end
