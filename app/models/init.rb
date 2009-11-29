tickets = %w(login_resolver ticket service_ticket proxy_ticket login_ticket ticket_granting_ticket) 
tickets.each{|f| require __DIR__(f)}