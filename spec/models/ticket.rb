require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Ticket do

  describe "DB_FIELDS" do
    it "should match attributes of tickets table" do
      @attributes = DB[:tickets].columns
      @attributes.map{|m| m.to_s}.sort.should == Ticket::DB_FIELDS.map{|m| m.to_s}.sort
    end
  end
  
  it 'should not initialize' do
    lambda { Ticket.new }.
           should.raise(RuntimeError).
           message.should.match(/abstract method/)
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
      cheese = MockTicket.new(ticket.ticket)
      cheese.ticket.should == ticket.ticket
      cheese.id.should.not == nil
      cheese.id.should == ticket.id
    end
    
    it "can update to database" do
      ticket = MockTicket.new
      ticket.save
      ticket.hostname = "cheesy.com"
      ticket.save
      cheese = MockTicket.new(ticket.ticket)
      cheese.hostname.should == 'cheesy.com'
    end
  end
end
