tickets = %w(ticket service_ticket proxy_ticket login_ticket ticket_granting_ticket) # proxy_granting_ticket proxy_granting_ticket_iou)
tickets.each{|f| require __DIR__(f)}