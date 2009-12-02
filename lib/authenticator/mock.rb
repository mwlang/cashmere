module Authenticator

  class MockAuth < BaseAuth
    def self.authenticate(username, password)
      @@valid_users[username] && @@valid_users[username] == password
    end

    def self.user_exists?(username)
      !!@@valid_users[username]
    end
    
    def self.configure(options)
      @@valid_users = options.first
      @@valid_users ||= {"demo" => "secret"}
    end
  end
  
end


