require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Login do
  behaves_like :rack_test

  should 'show login page' do
    response = get('/login')
    response.status.should == 200
    response['Content-Type'].should == 'text/html'
    response.should =~ /Login/
  end
  
  should 'show login page' do
    post('/login').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Login/
  end
  
end
