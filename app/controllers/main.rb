
class MainController < Controller
  helper :localize

  def index
    @title = "CAS Server"
    # redirect Login.route :/ if Ramaze.options.mode == :live
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end    
  
end
