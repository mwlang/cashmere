class LoginResolver
    
  ##
  # We initialize, choosing to err on the side of caution by only setting 
  # values if we have a valid set of conditions for having those values in the
  # request.  The request is then validated prior to returning.
  #
  def initialize(request)
    @request = request

    # service is always set
    @service = @request[:service]

    # login_ticket is only set on POSTs and if we find it (only validates once!)
    @login_ticket = LoginTicket.find(request[:lt], @service) if request.post?
    
    # username and password only set when we have a valid login ticket.
    @username = @request[:username] if @login_ticket
    @password = @request[:password] if @login_ticket
    
    # renew set if present and value is yes/true/1
    @renew = 0 == (@request[:renew] =~ /yes|YES|true|TRUE|1/)

    # gateway is only set when renew is not present AND we have a @service param
    @gateway = @renew ? false : !!@service && 0 == (@request[:gateway]  =~ /yes|YES|true|TRUE|1/)

    # warn is set if present and value is yes/true/1
    @warn = 0 == (@request[:warn] =~ /yes|YES|true|TRUE|1/)
    
    validate!
  end

  attr_reader :service, :renew, :warn, :login_ticket
  attr_reader :username, :password
  attr_reader :ticket_granting_cookie
  
  # A user validates when a valid cookie exists or good login credentials are supplied 
  def validate!
    validate_cookie || authenticate!
  end

  # A user authenticates when both a valid login ticket and good login crentials are supplied
  def authenticate!
    @request.post? && validate_login_ticket && validate_user
  end
  
  # A user is signed on if a valid ticket_granting_cookie exists
  def signed_in?    
    !!@ticket_granting_cookie
  end
  
  # Username comes from ticket granting cookie once signed on...
  def username
    signed_in? ? @ticket_granting_cookie.username.to_s : @username.to_s
  end
  
  # A user is only logged in if they authenticated successfully
  def logged_in?
    @logged_in ||= authenticate!
  end

  # A cookie is valid unless renew was specified or the ticket reached expiry
  def validate_cookie
    return true if signed_in?
        
    cookie = TicketGrantingTicket.find(@request.cookies[COOKIE_NAME])
    return false unless cookie
    
    if @renew or not cookie.valid?
      @request.delete_cookie(COOKIE_NAME)
    else
      @ticket_granting_cookie = cookie
    end

    signed_in?
  end

  # can only validate if we have a login ticket
  def validate_login_ticket
    !!@login_ticket && @login_ticket.valid? 
  end

  # can only validate on POST and we can authenticate the user's credentials
  def validate_user
    @user_validated ||= @request.post? && authenticate_user(@username, @password)
  end

  def authenticate_failed? 
    @request.post? && !logged_in?
  end
  
  def authenticate_failure_message
    Authenticator.user_exists?(@username) ? :invalid_password : :invalid_username
  end
  
  def params
    p = {}
    p.merge! :service => @service if @service
    p.merge! :warn => @warn if @warn
    p.merge! :renew => @renew if @renew
  end
  
  private
  
  # can only validate when both username and password are supplied
  def authenticate_user(username, password)
    @user_authenticated ||= !!@username && !!@password && Authenticator.authenticate(@username, @password)
  end
  
end
