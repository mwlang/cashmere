Class.new(Sequel::Migration) do
  def up
    create_table(:login_tickets, :ignore_index_errors=>true) do
      primary_key :id
      String :ticket, :null=>false
      DateTime :created_on, :null=>false
      DateTime :consumed
      String :client_hostname, :null=>false
      
      index [:ticket]
    end
    
    create_table(:proxy_granting_tickets, :ignore_index_errors=>true) do
      primary_key :id
      String :ticket, :null=>false
      DateTime :created_on, :null=>false
      String :client_hostname, :null=>false
      String :iou, :null=>false
      Integer :service_ticket_id, :null=>false
      
      index [:ticket]
    end
    
    create_table(:schema_info) do
      Integer :version
    end
    
    create_table(:service_tickets, :ignore_index_errors=>true) do
      primary_key :id
      String :ticket, :null=>false
      DateTime :created_on, :null=>false
      DateTime :consumed
      String :client_hostname, :null=>false
      String :service, :null=>false
      String :username, :null=>false
      String :type, :null=>false
      Integer :pgt_id
      
      index [:ticket]
    end
    
    create_table(:ticket_granting_tickets, :ignore_index_errors=>true) do
      primary_key :id
      String :ticket, :null=>false
      DateTime :created_on, :null=>false
      DateTime :consumed
      String :client_hostname, :null=>false
      
      index [:ticket]
    end
  end
  
  def down
    drop_table(:login_tickets, :proxy_granting_tickets, :schema_info, :service_tickets, :ticket_granting_tickets)
  end
end
