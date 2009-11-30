=begin

    * Login tickets issued by /login MUST be probabilistically unique.

    * Login tickets MUST only be valid for one authentication attempt. Whether or not authentication was successful,
      CAS MUST then invalidate the login ticket, causing all future authentication attempts with that instance of
      that login ticket to fail.

    * Login tickets SHOULD begin with the characters, "LT-".

=end


class LoginTicket < ServiceTicket

  protected 
    
  def ticket_prefix; "LT-" end
end