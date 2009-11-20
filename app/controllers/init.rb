# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout :application
  helper :localize
  engine :Erubis

  before_all { set_headers_to_prevent_caching }
  before_all { set_default_title }
  
  private
  
  def set_default_title
    @title = translate :cas_server
  end
  
  def set_headers_to_prevent_caching
    response.headers['Pragma'] = 'no-cache'
    response.headers['Cache-Control'] = 'no-store'
    response.headers['Expires'] = (Time.now - 1.year).rfc2822
  end
end

# Here go your requires for subclasses of Controller:
require __DIR__('main')
require __DIR__('login')
require __DIR__('logout')
require __DIR__('validate')
require __DIR__('service_validate')
require __DIR__('proxy_validate')
require __DIR__('proxy')
