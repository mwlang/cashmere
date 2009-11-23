require 'digest/sha1'

class Ticket
  SEED = 4.times.inject(Time.now.to_i){|t, n| t += rand(n)}
  DB_FIELDS = %w(id ticket created_at ticket_id hostname service username)

  attr_accessor :attributes
  
  def initialize(ticket = nil)
    @attributes = DB_FIELDS.inject({}){|a, df| a.merge!({df.to_sym => nil}) }
    DB_FIELDS.each{|df| eval("def #{df}; @attributes[:#{df}]; end")}
    DB_FIELDS.each{|df| eval("def #{df}=(v); @attributes[:#{df}] = v; end")}
    ticket.nil? ? new_ticket : find_ticket(ticket)
  end

  def ticket_prefix
    raise "abstract method"
  end
  
  def new_ticket
    @attributes[:ticket] = ticket_prefix + Digest::SHA1.hexdigest(rand(SEED).to_s)
    @attributes[:created_at] = Time.now
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

end  

# Used for testing since the base class raises exception 
# when abstract method not overridden
class MockTicket < Ticket
  def ticket_prefix
    "MOCK-"
  end
end

    # class LoginTicket < ActiveRecord::Base
    # 
    #   def self.generate_from(client_host)
    #     create! :client_hostname => client_host
    #   end
    # 
    #   def self.validate_ticket(ticket)
    #     return Castronaut::TicketResult.new(nil, MissingMessage) if ticket.nil?
    # 
    #     login_ticket = find_by_ticket(ticket)
    # 
    #     return Castronaut::TicketResult.new(nil, InvalidMessage) if login_ticket.nil?
    # 
    #     return Castronaut::TicketResult.new(login_ticket, AlreadyConsumedMessage) if login_ticket.consumed?
    # 
    #     return Castronaut::TicketResult.new(login_ticket, ExpiredMessage) if login_ticket.expired?
    # 
    #     login_ticket.consume!
    # 
    #     Castronaut::TicketResult.new(login_ticket, nil, "success")
    #   end
    # 
    #   def expired?
    #     #Time.now - lt.created_on < CASServer::Conf.login_ticket_expiry
    #   end
    #  
    #   def ticket_prefix
    #     "LT"
    #   end
    #   
    #   def username
    #   end
    #   
    #   def proxies
    #   end
    #   
    # end
    # 
