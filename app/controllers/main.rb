class MainController < Controller
  # the index action is called automatically when no other action is specified
  def index
    @title = "Welcome to Ramaze!"
    # redirect Login.route :/
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
end
