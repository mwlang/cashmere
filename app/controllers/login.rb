=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.1. /login as credential requestor

The /login URI operates with two behaviors: as a credential requestor, and as a
credential acceptor. It responds to credentials by acting as a credential acceptor and
otherwise acts as a credential requestor.

If the client has already established a single sign-on session with CAS, the web
browser presents to CAS a secure cookie containing a string identifying a
ticket-granting ticket. This cookie is called the ticket-granting cookie. If the
ticket-granting cookie keys to a valid ticket-granting ticket, CAS may issue a service
ticket provided all the other conditions in this specification are met. See Section 3.6
for more information on ticket-granting cookies.

2.1.1. parameters

The following HTTP request parameters may be passed to /login while it is acting as a
credential requestor. They are all case-sensitive, and they all MUST be handled by
/login.

    * service [OPTIONAL] - the identifier of the application the client is trying to
      access. In almost all cases, this will be the URL of the application. Note that
      as an HTTP request parameter, this URL value MUST be URL-encoded as described in
      Section 2.2 of RFC 1738[4]. If a service is not specified and a single sign-on
      session does not yet exist, CAS SHOULD request credentials from the user to
      initiate a single sign-on session. If a service is not specified and a single
      sign-on session already exists, CAS SHOULD display a message notifying the client
      that it is already logged in.

    * renew [OPTIONAL] - if this parameter is set, single sign-on will be bypassed. In
      this case, CAS will require the client to present credentials regardless of the
      existence of a single sign-on session with CAS. This parameter is not compatible
      with the "gateway" parameter. Services redirecting to the /login URI and login
      form views posting to the /login URI SHOULD NOT set both the "renew" and
      "gateway" request parameters. Behavior is undefined if both are set. It is
      RECOMMENDED that CAS implementations ignore the "gateway" parameter if "renew" is
      set. It is RECOMMENDED that when the renew parameter is set its value be "true".

    * gateway [OPTIONAL] - if this parameter is set, CAS will not ask the client for
      credentials. If the client has a pre-existing single sign-on session with CAS, or
      if a single sign-on session can be established through non-interactive means
      (i.e. trust authentication), CAS MAY redirect the client to the URL specified by
      the "service" parameter, appending a valid service ticket. (CAS also MAY
      interpose an advisory page informing the client that a CAS authentication has
      taken place.) If the client does not have a single sign-on session with CAS, and
      a non-interactive authentication cannot be established, CAS MUST redirect the
      client to the URL specified by the "service" parameter with no "ticket" parameter
      appended to the URL. If the "service" parameter is not specified and "gateway" is
      set, the behavior of CAS is undefined. It is RECOMMENDED that in this case, CAS
      request credentials as if neither parameter was specified. This parameter is not
      compatible with the "renew" parameter. Behavior is undefined if both are set. It
      is RECOMMENDED that when the gateway parameter is set its value be "true".

2.1.2. URL examples of /login

Simple login example:
  https://server/cas/login?service=http%3A%2F%2Fwww.service.com

Don't prompt for username/password:
  https://server/cas/login?service=http%3A%2F%2Fwww.service.com&gateway=true

Always prompt for username/password:
  https://server/cas/login?service=http%3A%2F%2Fwww.service.com&renew=true

2.1.3. response for username/password authentication

When /login behaves as a credential requestor, the response will vary depending on the
type of credentials it is requesting. In most cases, CAS will respond by displaying a
login screen requesting a username and password. This page MUST include a form with the
parameters, "username", "password", and "lt". The form MAY also include the parameter,
"warn". If "service" was specified to /login, "service" MUST also be a parameter of the
form, containing the value originally passed to /login. These parameters are discussed
in detail in Section 2.2.1. The form MUST be submitted through the HTTP POST method to
/login which will then act as a credential acceptor, discussed in Section 2.2.

2.1.4. response for trust authentication

Trust authentication accommodates consideration of arbitrary aspects of the request as
a basis for authentication. The appropriate user experience for trust authentication
will be highly deployer-specific in consideration of local policy and of the logistics
of the particular authentication mechanism implemented.

When /login behaves as a credential requestor for trust authentication, its behavior
will be determined by the type of credentials it will be receiving. If the credentials
are valid, CAS MAY transparently redirect the user to the service. Alternately, CAS MAY
display a warning that credentials were presented and allow the client to confirm that
it wants to use those credentials. It is RECOMMENDED that CAS implementations allow the
deployer to choose the preferred behavior. If the credentials are invalid or
non-existent, it is RECOMMENDED that CAS display to the client the reason
authentication failed, and possibly present the user with alternate means of
authentication (e.g. username/password authentication).

2.1.5. response for single sign-on authentication

If the client has already established a single sign-on session with CAS, the client
will have presented its HTTP session cookie to /login and behavior will be handled as
in Section 2.2.4. However, if the "renew" parameter is set, the behavior will be
handled as in Section 2.1.3 or 2.1.4.

2.2. /login as credential acceptor

When a set of accepted credentials are passed to /login, /login acts as a credential
acceptor and its behavior is defined in this section.

2.2.1. parameters common to all types of authentication

The following HTTP request parameters MAY be passed to /login while it is acting as a
credential acceptor. They are all case-sensitive and they all MUST be handled by
/login.

    * service [OPTIONAL] - the URL of the application the client is trying to access.
      CAS MUST redirect the client to this URL upon successful authentication. This is
      discussed in detail in Section 2.2.4.

    * warn [OPTIONAL] - if this parameter is set, single sign-on MUST NOT be
      transparent. The client MUST be prompted before being authenticated to another
      service.

2.2.2. parameters for username/password authentication

In addition to the OPTIONAL parameters specified in Section 2.2.1, the following HTTP
request parameters MUST be passed to /login while it is acting as a credential acceptor
for username/password authentication. They are all case-sensitive.

    * username [REQUIRED] - the username of the client that is trying to log in

    * password [REQUIRED] - the password of the client that is trying to log in

    * lt [REQUIRED] - a login ticket. This is provided as part of the login form
      discussed in Section 2.1.3. The login ticket itself is discussed in Section 3.5.

2.2.3. parameters for trust authentication

There are no REQUIRED HTTP request parameters for trust authentication. Trust
authentication may be based on any aspect of the HTTP request.

2.2.4. response

One of the following responses MUST be provided by /login when it is operating as a
credential acceptor.

    * successful login: redirect the client to the URL specified by the "service"
      parameter in a manner that will not cause the client's credentials to be
      forwarded to the service. This redirection MUST result in the client issuing a
      GET request to the service. The request MUST include a valid service ticket,
      passed as the HTTP request parameter, "ticket". See Appendix B for more
      information. If "service" was not specified, CAS MUST display a message notifying
      the client that it has successfully initiated a single sign-on session.

    * failed login: return to /login as a credential requestor. It is RECOMMENDED in
      this case that the CAS server display an error message be displayed to the user
      describing why login failed (e.g. bad password, locked account, etc.), and if
      appropriate, provide an opportunity for the user to attempt to login again. 
=end

VALID_USERS = {"mwlang" => "mwlang", "demo" => "secret"}

class Login < Controller
  
  def index
    get_params
    if logged_in?
      @title = translate :cas_server
      handle_logged_in_session
    else
      @title = translate :login_title
      handle_login_request_session
    end
  end

  def continue
    flash[:notice] = translate(:continue_message).gsub("%url%", request[:url])
  end

  private

  def handle_logged_in_session
    redirect @service if !@warn && @service && @service == @ticket_granting_ticket.service
    redirect Login.route(:continue, :url => @service) if @service
    
    flash[:notice] = translate(:logged_in_message).gsub('%username%', @ticket_granting_ticket.username.to_s)
  end
  
  def handle_login_request_session
    if authenticated?
      @ticket_granting_ticket = TicketGrantingTicket.new(@username).save
      response.set_cookie("ticket_granting_ticket", @ticket_granting_ticket.ticket)
      
      redirect :success unless @service
      redirect route(:continue, :url => @service) if @warn
      redirect @service
    end
    @new_login_ticket = LoginTicket.new(@service).save
  end
  
  def logged_in?
    @ticket_granting_ticket = TicketGrantingTicket.find(request.cookies["ticket_granting_ticket"])
    @ticket_granting_ticket
  end
  
  def authenticate
    valid_login_ticket && valid_user
  end
  
  def authenticated?    
    @authenticated ||= authenticate
  end
  
  def get_params
    @service = request[:service]
    @login_ticket = LoginTicket.find(@service, request[:lt]) if request.post?

    @username   =   request[:username] if @login_ticket
    @password   =   request[:password] if @login_ticket
    @renew      =   0 == (request[:renew] =~ /yes|YES|true|TRUE|1/)
    @gateway    =   @renew ? false : !!@service && 0 == (request[:gateway]  =~ /yes|YES|true|TRUE|1/)
    @warn       =   0 == (request[:warn] =~ /yes|YES|true|TRUE|1/)
  end
    
  def valid_login_ticket
    valid = @login_ticket && @login_ticket.valid?
    if !valid && request.post?
      flash[:error] = translate :invalid_login_ticket unless (@login_ticket && @login_ticket.valid?)
    end
    valid
  end
  
  def valid_user
    valid = @username && @password && VALID_USERS[@username] == @password
    if request.post? && !valid
      flash[:error] = translate VALID_USERS[@username] ? :invalid_password : :invalid_username
    end
    valid
  end
end
