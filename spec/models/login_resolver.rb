require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class MockAuthRequest 
  attr_accessor :params, :cookies, :query
  
  def initialize(req, params, cookies, query)
    @params = params
    @cookies = cookies
    @query = query
    @post = req == :post
  end
  
  def post?; @post; end
  def get?; !@post; end
  def [](value); @query[value] || @params[value]; end
end

VALID_GOOGLE_SERVICE = "http://www.google.com"
QUERY_WITH_SERVICE = {:service => VALID_GOOGLE_SERVICE}

VALID_PARAMS_W_SVC = {:username => "demo", 
    :password => "secret", 
    :lt => LoginTicket.new(VALID_GOOGLE_SERVICE).save.ticket,
    :service => VALID_GOOGLE_SERVICE
    }

VALID_PARAMS_WO_SVC = {:username => "demo", 
    :password => "secret", 
    :lt => LoginTicket.create.ticket
    }

INVALID_CREDS_W_SVC = {:username => "demo", 
    :password => "public", 
    :lt => LoginTicket.new(VALID_GOOGLE_SERVICE).save.ticket,
    :service => VALID_GOOGLE_SERVICE
    }

VALID_CREDS_INVALID_LT_W_SVC = {:username => "demo", 
    :password => "secret", 
    :lt => LoginTicket.new(VALID_GOOGLE_SERVICE).ticket,
    :service => VALID_GOOGLE_SERVICE
    }

COOKIES = {COOKIE_NAME => TicketGrantingTicket.create("vip").ticket}

BASIC_VALID_GET_REQ = MockAuthRequest.new(:get, {}, {}, QUERY_WITH_SERVICE)
VALID_GET_REQ_W_COOKIE = MockAuthRequest.new(:get, {}, COOKIES, QUERY_WITH_SERVICE)

BASIC_VALID_POST_REQ = MockAuthRequest.new(:post, VALID_PARAMS_W_SVC, {}, {})
VALID_POST_REQ_NO_SVC = MockAuthRequest.new(:post, VALID_PARAMS_WO_SVC, {}, {})
BASIC_VALID_POST_INVALID_CREDS_REQ = MockAuthRequest.new(:post, INVALID_CREDS_W_SVC, {}, {})
BASIC_VALID_POST_INVALID_LT_REQ = MockAuthRequest.new(:post, VALID_CREDS_INVALID_LT_W_SVC, {}, {})

describe LoginResolver do
  describe "A basic valid GET request with no cookies" do
    
    should "not have any params" do 
      BASIC_VALID_GET_REQ.params.should == {}
    end
    should "not have a ticket_granting_cookie" do 
      cookie = BASIC_VALID_GET_REQ.cookies[COOKIE_NAME]
      cookie.should == nil
    end
    should "not have user credentials" do
      cookie = BASIC_VALID_GET_REQ.cookies[COOKIE_NAME]
      cookie.should == nil
    end
    
    @resolver = LoginResolver.new(BASIC_VALID_GET_REQ)
  
    should "not authenticate!" do 
      @resolver.authenticate!.should == false 
      LoginResolver.new(BASIC_VALID_GET_REQ).authenticate!.should == false 
    end
    should "not validate!" do 
      @resolver.validate!.should == false 
      LoginResolver.new(BASIC_VALID_GET_REQ).validate!.should == false 
    end
    should "not be logged in" do
      @resolver.logged_in?.should == false 
      LoginResolver.new(BASIC_VALID_GET_REQ).logged_in?.should == false 
    end
    should "not be signed in" do
      @resolver.signed_in?.should == false 
      LoginResolver.new(BASIC_VALID_GET_REQ).signed_in?.should == false 
    end
    should "not validate login ticket" do
      @resolver.validate_login_ticket.should == false 
      LoginResolver.new(BASIC_VALID_GET_REQ).validate_login_ticket.should == false 
    end
    should "not validate user" do 
      @resolver.validate_user.should == false
      LoginResolver.new(BASIC_VALID_GET_REQ).validate_user.should == false
    end
    should "not authenticate" do
      @resolver.authenticate!.should == false
      LoginResolver.new(BASIC_VALID_GET_REQ).authenticate!.should == false
    end
    should "not validate cookie" do 
      @resolver.validate_cookie.should == false
      LoginResolver.new(BASIC_VALID_GET_REQ).validate_cookie.should == false
    end
  end

  describe "A basic valid GET request with valid ticket-granting-ticket cookie" do
    
    should "not have any params" do 
      VALID_GET_REQ_W_COOKIE.params.should == {}
    end
    
    should "have a ticket_granting_cookie" do 
      cookie = VALID_GET_REQ_W_COOKIE.cookies[COOKIE_NAME]
      cookie.should.not == nil
    end
        
    @resolver = LoginResolver.new(VALID_GET_REQ_W_COOKIE)
  
    should "not authenticate!" do 
      @resolver.authenticate!.should == false 
    end
    should "validate!" do 
      @resolver.validate!.should == true
    end
    should "not be logged in" do
      @resolver.logged_in?.should == false
    end
    should "be signed in" do
      @resolver.signed_in?.should == true
    end
    should "not validate login ticket" do
      @resolver.validate_login_ticket.should == false 
    end
    should "not validate user" do 
      @resolver.validate_user.should == false
    end
    should "not authenticate" do
      @resolver.authenticate!.should == false
    end
    should "validate cookie" do 
      @resolver.validate_cookie.should == true
    end
    should "have a username that is associated with the cookie" do 
      @resolver.username.should == "vip"
    end
  end
  
  describe "A valid POST request supplying CORRECT credentials" do
    should "be a POST request" do
      BASIC_VALID_POST_REQ.post?.should == true
    end
    should "have a username, password, and login_ticket" do
      BASIC_VALID_POST_REQ.params[:username].should == 'demo'
      BASIC_VALID_POST_REQ.params[:password].should == 'secret'
    end
    should "have a login ticket param" do 
      BASIC_VALID_POST_REQ.params[:lt].should =~ /^LT-/
    end
    should "have a service parameter" do
      BASIC_VALID_POST_REQ[:service].should == VALID_GOOGLE_SERVICE
    end
    should "find the login ticket in the database" do 
      DB[:tickets].filter(:ticket => BASIC_VALID_POST_REQ.params[:lt]).count.should == 1
    end
    
    @resolver = LoginResolver.new(BASIC_VALID_POST_REQ)
    
    should "authenticate!" do 
      @resolver.authenticate!.should == true
    end
    should "validate!" do 
      @resolver.validate!.should == true 
    end
    should "be logged in" do
      @resolver.logged_in?.should == true 
    end
    should "not be signed in" do
      @resolver.signed_in?.should == false
      LoginResolver.new(BASIC_VALID_POST_REQ).signed_in?.should == false
    end
    should "validate login ticket" do
      @resolver.validate_login_ticket.should == true 
    end
    should "not validate login ticket for other request" do
      LoginResolver.new(BASIC_VALID_POST_REQ).validate_login_ticket.should == false
    end
    should "still have valid login ticket for original request" do
      @resolver.validate_login_ticket.should == true 
    end
    should "validate user" do 
      @resolver.validate_user.should == true
    end
    should "authenticate" do
      @resolver.authenticate!.should == true
    end
    should "not validate cookie" do 
      @resolver.validate_cookie.should == false
    end
  end

  describe "A valid POST request supplying INCORRECT credentials" do
    should "be a POST request" do
      BASIC_VALID_POST_INVALID_CREDS_REQ.post?.should == true
    end
    should "have a username, password, and login_ticket" do
      BASIC_VALID_POST_INVALID_CREDS_REQ.params[:username].should == 'demo'
      BASIC_VALID_POST_INVALID_CREDS_REQ.params[:password].should == 'public'
    end
    should "have a login ticket param" do 
      BASIC_VALID_POST_INVALID_CREDS_REQ.params[:lt].should =~ /^LT-/
    end
    should "have a service parameter" do
      BASIC_VALID_POST_INVALID_CREDS_REQ[:service].should == VALID_GOOGLE_SERVICE
    end
    should "find the login ticket in the database" do 
      DB[:tickets].filter(:ticket => BASIC_VALID_POST_INVALID_CREDS_REQ.params[:lt]).count.should == 1
    end
    
    @resolver = LoginResolver.new(BASIC_VALID_POST_INVALID_CREDS_REQ)
    
    should "not authenticate!" do 
      @resolver.authenticate!.should == false
    end
    should "not validate!" do 
      @resolver.validate!.should == false
    end
    should "not be logged in" do
      @resolver.logged_in?.should == false
    end
    should "not be signed in" do
      @resolver.signed_in?.should == false
      LoginResolver.new(BASIC_VALID_POST_REQ).signed_in?.should == false
    end
    should "validate login ticket" do
      @resolver.validate_login_ticket.should == true 
    end
    should "not validate user" do 
      @resolver.validate_user.should == false
    end
    should "not authenticate" do
      @resolver.authenticate!.should == false
    end
    should "not validate cookie" do 
      @resolver.validate_cookie.should == false
    end
  end
         
  describe "A valid POST request supplying INCORRECT login ticket" do
    should "be a POST request" do
      BASIC_VALID_POST_INVALID_LT_REQ.post?.should == true
    end
    should "have a username, password, and login_ticket" do
      BASIC_VALID_POST_INVALID_LT_REQ.params[:username].should == 'demo'
      BASIC_VALID_POST_INVALID_LT_REQ.params[:password].should == 'secret'
    end
    should "have a login ticket param" do 
      BASIC_VALID_POST_INVALID_LT_REQ.params[:lt].should =~ /^LT-/
    end
    should "have a service parameter" do
      BASIC_VALID_POST_INVALID_LT_REQ[:service].should == VALID_GOOGLE_SERVICE
    end
    should "find the login ticket in the database" do 
      DB[:tickets].filter(:ticket => BASIC_VALID_POST_INVALID_LT_REQ.params[:lt]).count.should == 0
    end
    
    @resolver = LoginResolver.new(BASIC_VALID_POST_INVALID_LT_REQ)
    
    should "not authenticate!" do 
      @resolver.authenticate!.should == false
    end
    should "not validate!" do 
      @resolver.validate!.should == false
    end
    should "not be logged in" do
      @resolver.logged_in?.should == false
    end
    should "not be signed in" do
      @resolver.signed_in?.should == false
      LoginResolver.new(BASIC_VALID_POST_REQ).signed_in?.should == false
    end
    should "not validate login ticket" do
      @resolver.validate_login_ticket.should == false 
    end
    should "not validate user" do 
      @resolver.validate_user.should == false
    end
    should "not authenticate" do
      @resolver.authenticate!.should == false
    end
    should "not validate cookie" do 
      @resolver.validate_cookie.should == false
    end
  end

  describe "A valid POST request supplying CORRECT credentials w/o SERVICE" do
    should "be a POST request" do
      VALID_POST_REQ_NO_SVC.post?.should == true
    end
    should "have a username, password, and login_ticket" do
      VALID_POST_REQ_NO_SVC.params[:username].should == 'demo'
      VALID_POST_REQ_NO_SVC.params[:password].should == 'secret'
    end
    should "have a login ticket param" do 
      VALID_POST_REQ_NO_SVC.params[:lt].should =~ /^LT-/
    end
    should "not have a service parameter" do
      VALID_POST_REQ_NO_SVC[:service].should == nil
    end
    should "find the login ticket in the database" do 
      DB[:tickets].filter(:ticket => VALID_POST_REQ_NO_SVC.params[:lt]).count.should == 1
    end
    
    @resolver = LoginResolver.new(VALID_POST_REQ_NO_SVC)

    should "validate login ticket" do
      @resolver.validate_login_ticket.should == true 
    end
    should "authenticate!" do 
      @resolver.authenticate!.should == true
    end
    should "validate!" do 
      @resolver.validate!.should == true 
    end
    should "be logged in" do
      @resolver.logged_in?.should == true 
    end
    should "not be signed in" do
      @resolver.signed_in?.should == false
      LoginResolver.new(VALID_POST_REQ_NO_SVC).signed_in?.should == false
    end
    should "not validate login ticket for other request" do
      LoginResolver.new(VALID_POST_REQ_NO_SVC).validate_login_ticket.should == false
    end
    should "still have valid login ticket for original request" do
      @resolver.validate_login_ticket.should == true 
    end
    should "validate user" do 
      @resolver.validate_user.should == true
    end
    should "authenticate" do
      @resolver.authenticate!.should == true
    end
    should "not validate cookie" do 
      @resolver.validate_cookie.should == false
    end    
  end

end


  # def validate!
  # def authenticate!
  # def signed_in?
  # def logged_in?
  # def validate_cookie
  # def validate_login_ticket
  # def validate_user
  # def authenticate_user(username, password)
