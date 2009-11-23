require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe MainController do
  behaves_like :rack_test

  it 'should show start page' do
    puts Ramaze.options.roots.inspect 
    get('/').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should.not == ''
    last_response.body.should =~ /proxy/
  end
  
end
