=begin

    * Ticket-granting cookies MUST be set to expire at the end of the client's browser session.

    * CAS MUST set the cookie path to be as restrictive as possible. For example, if the CAS server is set up under the
      path /cas, the cookie path MUST be set to /cas.

    * The value of ticket-granting cookies MUST contain adequate secure random data so that a ticket-granting cookie is
      not guessable in a reasonable period of time.

    * The value of ticket-granting cookies SHOULD begin with the characters, "TGC-".

=end

class TicketGrantingTicket < Ticket
  def ticket_prefix; "TGT-" end
  
  def initialize(username)
    super(nil)
    @attributes[:username] = username if username
  end
  
end