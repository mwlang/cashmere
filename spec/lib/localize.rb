require File.join('..', 'spec_helper')

describe Rack::Localize do
  app = lambda { |env| [200, {'Content-Type' => 'text/html'}, env['PATH_INFO']] }
  lm = Rack::Localize.new(app)
  request_en = Rack::MockRequest.env_for("/", "HTTP_ACCEPT_LANGUAGE" => "en")


  should 'rank locales by queue priority' do
    lm.rank_locales('').should == []
    lm.rank_locales('en').should == ['en']
    lm.rank_locales('da, en-gb;q=0.8, en;q=0.7').should == ['da', 'en-GB', 'en']
    lm.rank_locales('en-gb;q=0.5, en;q=0.7, pt-BR').should == ['pt-BR', 'en', 'en-GB']
    lm.rank_locales('zh, en-us; q=0.8, en; q=0.6').should == ['zh', 'en-US', 'en']
  end

  describe "A request from U.S.A" do 
    request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT_LANGUAGE" => "en-US")

    should "not have a rack.locale in the request environment before processing" do
      request["rack.locale"].should == nil
    end
    
    status, headers, body = lm.call(request)

    should "set rack.locale in the request environment" do 
      status.should == 200
      body.should == "/"
      request["rack.locale"].should == 'en-US'
    end

    should "set Content-Language in the headers" do 
      headers["Content-Language"].should == "en-US"
    end

    should "set I18n.locale" do 
      I18n.locale.should == :'en-US'
    end

    should "translate username to English" do
      username = I18n.translate :username
      username.upcase.should == 'E-MAIL ADDRESS'
    end
  end
    
  describe "A request from Brazil" do 
    request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT_LANGUAGE" => "pt-br, en-gb;q=0.8, en;q=0.7")

    should "not have a rack.locale in the request environment before processing" do
      request["rack.locale"].should == nil
    end
    
    status, headers, body = lm.call(request)

    should "set rack.locale in the request environment" do 
      status.should == 200
      body.should == "/"
      request["rack.locale"].should == 'pt-BR'
    end

    should "set Content-Language in the headers" do 
      headers["Content-Language"].should == "pt-BR"
    end

    should "set I18n.locale" do 
      I18n.locale.should == :'pt-BR'
    end
    
    should "translate username to Portuguese" do
      username = I18n.translate :username
      username.should == 'Conta de correio electrónico'
    end
  end
  
  describe "A request for 'en'" do 
    request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT_LANGUAGE" => "en-gb;q=0.8, en;q=0.9")

    should "not have a rack.locale in the request environment before processing" do
      request["rack.locale"].should == nil
    end
    
    status, headers, body = lm.call(request)

    should "set rack.locale in the request environment" do 
      status.should == 200
      body.should == "/"
      request["rack.locale"].should == 'en'
    end

    should "set Content-Language in the headers" do 
      headers["Content-Language"].should == "en"
    end

    should "set I18n.locale" do 
      I18n.locale.should == :'en'
    end
    
    should "translate username to English" do
      username = I18n.translate :username
      username.upcase.should == 'E-MAIL ADDRESS'
    end
  end
end
