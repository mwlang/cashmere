require File.join('..', 'spec_helper')

describe Login do
  behaves_like :rack_test

  should 'show login page' do
    get('/login').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Login/
  end
  
  should 'show login page' do
    post('/login').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Login/
  end
  
  should 'turn caching off via headers' do 
    get('/login').status.should == 200
    last_response.headers['Pragma'].should == 'no-cache'
    Time.parse(last_response.headers['Expires']).should < Time.now
    last_response.headers['Cache-Control'].should == 'no-store'
  end
  
end
