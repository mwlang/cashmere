require File.join('..', 'spec_helper')

describe MainController do
  behaves_like :rack_test

  should 'show start page' do
    get('/').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /CAS Server/
  end

  should 'turn caching off via headers' do 
    get('/').status.should == 200
    last_response.headers['Pragma'].should == 'no-cache'
    Time.parse(last_response.headers['Expires']).should < Time.now
    last_response.headers['Cache-Control'].should == 'no-store'
  end

  should 'show /notemplate' do
    get('/notemplate').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /there is no 'notemplate\.xhtml' associated with this action/
  end
end
