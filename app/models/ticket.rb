require 'digest/sha1'

class Ticket
  attr_accessor :attributes
  
  DB_FIELDS = %w(id ticket created_at ticket_id hostname service username)
  DB_FIELDS.each{|df| class_eval("def #{df}; @attributes[:#{df}]; end")}
  DB_FIELDS.each{|df| class_eval("def #{df}=(v); @attributes[:#{df}] = v; end")}

  RAND_SEED = 4.times.inject(Time.now.to_i){|t, n| t += rand(n)}
  FIVE_MINUTES = 5 * 60 

  def self.find(ticket)
    # ensure ticket isn't malformed before attempting to fetch
    return nil unless sane_ticket(ticket)
    
    ticket = DB[:tickets].filter(:ticket => ticket).first
    ticket ? new(ticket) : nil
  end
  
  def self.create
    new.save
  end
  
  def initialize(values = nil)
    if values
      @attributes = values
    else  
      @attributes = DB_FIELDS.inject({}){|a, df| a.merge!({df.to_sym => nil}) }
      @attributes[:ticket] = self.ticket_prefix + Digest::SHA1.hexdigest(rand(RAND_SEED).to_s)
      @attributes[:created_at] = Time.now
    end
  end

  def find_ticket(ticket)
    @attributes = DB[:tickets].filter(:ticket => ticket).first
    unless @attributes 
      @attributes = {}
      @attributes[:ticket] = ticket
    end
  end
    
  def save
    if @attributes[:id]
      DB[:tickets].filter(:id => self.id).update(@attributes)
    else
      @attributes[:id] = DB[:tickets].insert(@attributes)
    end
    self
  end

  def expire!
    DB[:tickets].filter(:id => self.id).delete
  end
  
  def expired?
    (Time.now - @attributes[:created_at]) > lifespan
  end  

  private 
  
  def self.sane_ticket(ticket)
    ticket && (ticket.match(/^[a-zA-Z0-9-]*$/).to_s == ticket)
  end

  protected 
  
  def lifespan
    FIVE_MINUTES
  end
  
  def ticket_prefix
    raise "abstract method"
  end
  
end  

# Used for testing since the base class raises exception 
# when abstract method not overridden
class MockTicket < Ticket
  def ticket_prefix
    "MOCK-"
  end
end
