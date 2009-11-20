require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rack::NoCache do
  app = lambda { |env| [200, {'Content-Type' => 'text/html'}, env['PATH_INFO']] }
  request = Rack::MockRequest.env_for("/")
  status, headers, body = Rack::NoCache.new(app).call(request)
  
  describe 'A request should inject headers to prevent caching' do
    
    it "should be valid" do
      status.should == 200
      body.should == "/"
    end
    
    it "should have a Pragma header set to 'no-cache'" do 
      headers['Pragma'].should == 'no-cache'
    end
    
    it "should have Cache-Control header set to 'no-store'" do 
      headers['Cache-Control'].should == 'no-store'
    end
    
    it "should have an Expires header that expired a year ago" do
      Time.parse(headers['Expires']).should <= (Time.now - 1.year + 30.seconds)
    end
  end

end
