# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  helper :localize
  engine :Erubis

  layout :application
  map_layouts '/'

  before_all { @title = localize :cas_server }
  
  def locale(name)
    session[:lang] = name
    redirect r(:/)
  end
  
  private
  
  # Load the Internationalization files
  Dictionary = Ramaze::Helper::Localize::Dictionary.new
  Dir.glob(LOCALE_PATH).each do |path|
    Dictionary.load(File.basename(path, '.yaml').intern, :yaml => path)
  end

  def localize_dictionary
    Dictionary
  end
end

# Load each Controller:
controllers = %w(main login logout validate service_validate proxy_validate proxy)
controllers.each{|f| require __DIR__(f)}
