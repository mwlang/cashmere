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


class ProxyTicket < ServiceTicket
  def ticket_prefix; "PT-" end
end