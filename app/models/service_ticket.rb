=begin

  * Service tickets are only valid for the service identifier that was specified to /login when they were generated. The
    service identifier SHOULD NOT be part of the service ticket.

  * Service tickets MUST only be valid for one ticket validation attempt. Whether or not validation was successful, CAS MUST
    then invalidate the ticket, causing all future validation attempts of that same ticket to fail.

  * CAS SHOULD expire unvalidated service tickets in a reasonable period of time after they are issued. If a service presents
    for validation an expired service ticket, CAS MUST respond with a validation failure response. It is RECOMMENDED that the
    validation response include a descriptive message explaining why validation failed. It is RECOMMENDED that the duration a
    service ticket is valid before it expires be no longer than five minutes. Local security and CAS usage considerations MAY
    determine the optimal lifespan of unvalidated service tickets.

  * Service tickets MUST contain adequate secure random data so that a ticket is not guessable.

  * Service tickets MUST begin with the characters, "ST-".

  * Services MUST be able to accept service tickets of up to 32 characters in length. It is RECOMMENDED that services support
    service tickets of up to 256 characters in length.

=end

class ServiceTicket < Ticket
  FIVE_MINUTES = 5 * 60 
  
  attr_accessor :requesting_service
  
  def self.find(ticket, service = nil)
    # ensure ticket isn't malformed before attempting to fetch
    return nil unless sane_ticket(ticket)
    
    ticket = DB[:tickets].filter(:ticket => ticket).first
    if ticket
      ticket = new(ticket[:service], ticket)
      ticket.expire!
      ticket.requesting_service = service
    end
    ticket
  end
    
  def self.create(service = nil)
    new(service).save
  end
  
  def initialize(service, values = nil)
    super(values)
    @attributes[:service] = service
  end
  
  def ticket_prefix; "ST-" end

  def valid? 
    service_identifier_matches? && !expired?
  end
  
  def service_identifier_matches?
    @requesting_service == self.service
  end
  
  private

  def expired?
    (Time.now - @attributes[:created_at]) > FIVE_MINUTES
  end  
end
