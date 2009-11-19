
class MainController < Controller

  def index
    redirect Login.route :/ if Ramaze.options.mode == :live
    @title = "CAS Server"
  end

  def invalid
    @title = "Invalid Request"
  end
  
end
