require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Ticket do

  describe "DB_FIELDS" do
    it "should match attributes of tickets table" do
      @attributes = DB[:tickets].columns
      @attributes.map{|m| m.to_s}.sort.should == Ticket::DB_FIELDS.map{|m| m.to_s}.sort
    end
  end
  
  describe "Mocked Ticket" do
    
    it "should initialize" do 
      ticket = MockTicket.new
      ticket.should.not == nil
    end
    
    it "should have a ticket number" do
      ticket = MockTicket.new
      ticket.ticket.should =~ /MOCK-/
    end
    
    it "should have a long ticket number" do
      ticket = MockTicket.new
      ticket.ticket.size.should > 32
    end
    
    it "should not error with malformed ticket request" do
      ticket = MockTicket.find('234567890)((*&^%$#@!))')
      ticket.should == nil

      ticket = MockTicket.find('delete from tickets')
      ticket.should == nil

      ticket = MockTicket.find('<h1>not gonna do it</h1>')
      ticket.should == nil
    end
    
    it "should not have an id" do
      ticket = MockTicket.new
      ticket.id.should == nil
    end
    
    it "should only contain [a..z, A..Z, 0..9, -]" do
      ticket = MockTicket.new
      1000.times {t = MockTicket.new.ticket; t.match(/^[a-zA-Z0-9-]*$/).to_s.should == t}
    end
    
    it "should persist to the database" do 
      ticket = MockTicket.new
      ticket.save
      cheese = MockTicket.find(ticket.ticket)
      cheese.ticket.should == ticket.ticket
      cheese.id.should.not == nil
      cheese.id.should == ticket.id
    end
    
    it "can update to database" do
      ticket = MockTicket.new
      ticket.save
      ticket.hostname = "cheesy.com"
      ticket.save
      cheese = MockTicket.find(ticket.ticket)
      cheese.hostname.should == 'cheesy.com'
    end
    
    it "should save to database when created" do
      ticket = MockTicket.create
      cheese = MockTicket.find(ticket.ticket)
      cheese.should.not == nil
      cheese.id.should == ticket.id
      cheese.ticket.should == ticket.ticket
      cheese.is_a?(MockTicket).should == true
    end

    it "can be found and loaded" do
      ticket = MockTicket.create
      cheese = MockTicket.find(ticket.ticket)
      cheese.should.not == nil
      cheese.id.should == ticket.id
      cheese.ticket.should == ticket.ticket
      cheese.is_a?(MockTicket).should == true
    end

    it "non-existent tickets should not be findable" do
      MockTicket.find("MOCK-bogusticketthatshouldneverexist").should == nil
    end
    
  end
end
