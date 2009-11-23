# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  helper :localize
  engine :Erubis

  layout :application
  map_layouts '/'

  before_all { set_default_title }
  
  private
  
  def set_default_title
    @title = translate :cas_server
  end
end

# Load each Controller:
controllers = %w(main login logout validate service_validate proxy_validate proxy)
controllers.each{|f| require __DIR__(f)}
