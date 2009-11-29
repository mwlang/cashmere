=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.3. /logout

/logout destroys a client's single sign-on CAS session. The ticket-granting cookie (Section 3.6) is destroyed, and
subsequent requests to /login will not obtain service tickets until the user again presents primary credentials
(and thereby establishes a new single sign-on session).

2.3.1. parameters

The following HTTP request parameter MAY be specified to /logout. It is case sensitive and SHOULD be handled by
/logout.

    * url [OPTIONAL] - if "url" is specified, the URL specified by "url" SHOULD be on the logout page with
      descriptive text. For example, "The application you just logged out of has provided a link it would like you
      to follow. Please click here to access http://www.go-back.edu."

2.3.2. response

/logout MUST display a page stating that the user has been logged out. If the "url" request parameter is
implemented, /logout SHOULD also provide a link to the provided URL as described in Section 2.3.1.
=end

class Logout < Controller
  def index
    @url = request[:url]
    ticket = TicketGrantingTicket.find(request.cookies[COOKIE_NAME])
    response.delete_cookie(COOKIE_NAME)
    ticket.expire! if ticket
  end
end
