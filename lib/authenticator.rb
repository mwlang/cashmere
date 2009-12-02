##
# The Authenticator module provides a pluggable, configurable authentication
# framework that is easy to extend and configure.  The derived authenticator
# classes are lazily loaded only when actually referenced. To utilize a specific
# authenticator, declare via the use clause for that authenticator in the application startup.
# 
# For example:
#   Authenticator.use :MockAuth, [optional parameters]
# 
# Available authenticators:
#
# - MockAuth - Simple authenticator based on hash and only suitable for testing
#
module Authenticator  
  ## 
  # Iterates over each registered Auth class to try to authenticate the user.
  # The first one to succeed wins.
  #
  # @param [String] username  the user account name
  # @param [String] password  the secret code to validate
  # @return [true] if credentals validate
  # @return [false] if username doesn't exist or password does not validate
  #
  def self.authenticate(username, password)
    raise "no authenticators registered" if @@authenticators == []
    @@authenticators.detect{|a| a.authenticate(username, password)} != nil
  end

  ##
  # Checks each registered authenticater to see if username exists in any
  # of their databases.
  #
  # @param [String] username as the user account name
  # @return [true] if the username exists
  # @return [false] if the username does not exist
  #
  def self.user_exists?(username)
    raise "no authenticators registered" if @@authenticators == []
    @@authenticators.detect{|a| a.user_exists?(username)} != nil
  end

  ## 
  # Called in configuration/startup to tell the application which 
  # authentication methods should be utilized.  For example:
  #
  #   Authenticator.use :MockAuth
  #
  # Authenticators can take options, too, which are specific to
  # the implementation of each derivative class.  For example:
  #
  #   Authenticator.use :MockAuth, {"scooby" => "doo", "scrappy" => "too"}
  #
  def self.use(klass, *options)
    auth = eval(klass.to_s)
    authenticators.reject!{|r| r == auth}
    authenticators << auth
    authenticators.last.configure(options) if options
  end
  
  protected
  
  ##
  # BaseAuth provides the base abstract class from which to derive 
  # a new Authentication handler.  
  #
  class BaseAuth
    ##
    # Override this method in the derivative class to perform 
    # the necessary authorization. 
    #
    # @return [true] if and only if the username and password are validated
    # as correct.
    #
    # @return [false or nil] for all other circumstances
    #
    def self.authenticate(username, password)
      raise "abstract method" 
    end

    ##
    # Override this method in the derivative class to perform 
    # a lookup of the given username. 
    #
    # @return [true] if and only if the username exists
    #
    # @return [false or nil] for all other circumstances
    #
    def self.user_exists?(username)
      raise "abstract method" 
    end
    
    ## 
    # Override to pass configuration options
    # in to the derived authenticator class.
    #
    def self.configure(*options)
      raise "abstract method" 
    end
    
  end

  private

  def self.authenticators 
    @@authenticators ||= []
  end
  
  autoload :MockAuth, File.join(__DIR__, 'authenticator', 'mock')
  
end
