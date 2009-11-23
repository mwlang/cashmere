require 'digest/sha1'

class Ticket
  attr_accessor :attributes
  
  DB_FIELDS = %w(id ticket created_at ticket_id hostname service username)
  DB_FIELDS.each{|df| class_eval("def #{df}; @attributes[:#{df}]; end")}
  DB_FIELDS.each{|df| class_eval("def #{df}=(v); @attributes[:#{df}] = v; end")}

  def self.sane_ticket(ticket)
    ticket && (ticket.match(/^[a-zA-Z0-9-]*$/).to_s == ticket)
  end
  
  def self.find(ticket)
    # ensure ticket isn't malformed before attempting to fetch
    return nil unless sane_ticket(ticket)
    
    @attributes = DB[:tickets].filter(:ticket => ticket).first
    @attributes ? new(ticket).load_attributes(@attributes) : nil
  end
  
  def initialize(ticket = nil)
    unless ticket 
      @attributes = DB_FIELDS.inject({}){|a, df| a.merge!({df.to_sym => nil}) }
      @attributes[:ticket] = self.ticket_prefix + Digest::SHA1.hexdigest(rand(SEED).to_s)
      @attributes[:created_at] = Time.now
    end
  end

  def ticket_prefix
    raise "abstract method"
  end
  
  SEED = 4.times.inject(Time.now.to_i){|t, n| t += rand(n)}

  def load_attributes(values)
    @attributes = values
    self
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
end  

# Used for testing since the base class raises exception 
# when abstract method not overridden
class MockTicket < Ticket
  def ticket_prefix
    "MOCK-"
  end
end
